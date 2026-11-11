require "test_helper"

class TripTest < ActiveSupport::TestCase
  test "geocodes starting and ending locations" do
    trip = Trip.create!(name: "Road Trip", starting_location: "Denver", ending_location: "Seattle")

    assert_equal [ 39.7392, -104.9903 ], [ trip.starting_latitude, trip.starting_longitude ].map(&:to_f)
    assert_equal [ 47.6062, -122.3321 ], [ trip.ending_latitude, trip.ending_longitude ].map(&:to_f)
  end

  test "is invalid when a location can't be found" do
    trip = Trip.new(name: "Road Trip", starting_location: "Denver", ending_location: "Nowhereville")

    assert_not trip.valid?
    assert_includes trip.errors[:ending_location], "couldn't be found. Check the spelling, or try a less specific address (e.g. just the city)"
  end

  test "is invalid when the geocoding service is unavailable" do
    trip = Trip.new(name: "Road Trip", starting_location: "Denver", ending_location: "Seattle")

    original_search = Geocoder.method(:search)
    Geocoder.define_singleton_method(:search) { |*| raise Timeout::Error }
    begin
      assert_not trip.valid?
    ensure
      Geocoder.define_singleton_method(:search, original_search)
    end
    assert_includes trip.errors[:starting_location], "couldn't be looked up right now, please try again"
  end

  test "stores the driving route between the locations" do
    trip = Trip.create!(name: "Road Trip", starting_location: "Denver", ending_location: "Seattle")

    assert_equal 2_101_000.0, trip.route_distance
    assert_equal 72_000.0, trip.route_duration
    assert_equal [ [ -104.9903, 39.7392 ], [ -122.3321, 47.6062 ] ], trip.route_geometry
    assert_requested :post, OpenRouteService::URL,
      body: { coordinates: [ [ -104.9903, 39.7392 ], [ -122.3321, 47.6062 ] ] }.to_json
  end

  test "only looks up the route again when a location changes" do
    trip = Trip.create!(name: "Road Trip", starting_location: "Denver", ending_location: "Seattle")

    trip.update!(name: "Renamed Trip")
    assert_requested :post, OpenRouteService::URL, times: 1

    trip.update!(ending_location: "Denver")
    assert_requested :post, OpenRouteService::URL, times: 2
  end

  test "is invalid when there's no driving route" do
    stub_open_route_service_error(status: 404, error: { code: 2009, message: "Route could not be found" })
    trip = Trip.new(name: "Road Trip", starting_location: "Denver", ending_location: "Seattle")

    assert_not trip.valid?
    assert_includes trip.errors[:base], "There's no driving route between these locations"
  end

  test "is invalid when the route is too long to look up" do
    stub_open_route_service_error(status: 400, error: { code: 2004, message: "The approximated route distance must not be greater than 6000000.0 meters." })
    trip = Trip.new(name: "Road Trip", starting_location: "Denver", ending_location: "Seattle")

    assert_not trip.valid?
    assert_includes trip.errors[:base], "This trip is too long for driving directions (the limit is about 3,700 miles)"
  end

  test "is invalid when the routing service fails" do
    stub_open_route_service_error(status: 403, error: "Access to this API has been disallowed")
    trip = Trip.new(name: "Road Trip", starting_location: "Denver", ending_location: "Seattle")

    assert_not trip.valid?
    assert_includes trip.errors[:base], "Driving directions couldn't be looked up right now, please try again"
  end

  test "is invalid when the routing service times out" do
    stub_request(:post, OpenRouteService::URL).to_timeout
    trip = Trip.new(name: "Road Trip", starting_location: "Denver", ending_location: "Seattle")

    assert_not trip.valid?
    assert_includes trip.errors[:base], "Driving directions couldn't be looked up right now, please try again"
  end
end
