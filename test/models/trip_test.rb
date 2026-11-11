require "test_helper"

class TripTest < ActiveSupport::TestCase
  test "needs a start and an end" do
    trip = build_trip("Denver")

    assert_not trip.valid?
    assert_includes trip.errors[:base], "A trip needs a starting and an ending location"
  end

  test "can have up to 20 stops" do
    trip = build_trip(*[ "Denver", "Seattle" ] * 10)

    assert trip.valid?
  end

  test "can't have more than 20 stops, and doesn't look any of them up" do
    trip = build_trip(*[ "Denver", "Seattle" ] * 10, "Boise")

    assert_not trip.valid?
    assert_includes trip.errors[:base], "A trip can have at most 20 stops"
    assert trip.stops.none?(&:latitude)
    assert_not_requested :post, OpenRouteService::URL
  end

  test "numbers its stops in the order they were given" do
    trip = build_trip("Seattle", "Boise", "Denver")
    trip.save!

    assert_equal [ [ "Seattle", 1 ], [ "Boise", 2 ], [ "Denver", 3 ] ], trip.stops.reload.map { |stop| [ stop.location, stop.position ] }
  end

  test "starts at its first stop and ends at its last" do
    trip = build_trip("Denver", "Boise", "Seattle")
    trip.save!

    assert_equal "Denver", trip.starting_stop.location
    assert_equal "Seattle", trip.ending_stop.location
  end

  test "is invalid when a stop is invalid" do
    trip = build_trip("Denver", "Nowhereville")

    assert_not trip.valid?
    assert_not_requested :post, OpenRouteService::URL
  end

  test "stores the driving route of each leg on the stop it arrives at" do
    trip = build_trip("Denver", "Boise", "Seattle")
    trip.save!

    denver, boise, seattle = trip.stops
    assert_nil denver.route_distance
    assert_equal 2_101_000.0, boise.route_distance
    assert_equal 72_000.0, seattle.route_duration
    assert_requested :post, OpenRouteService::URL, body: { coordinates: [ [ -104.9903, 39.7392 ], [ -116.2023, 43.615 ] ] }.to_json
    assert_requested :post, OpenRouteService::URL, body: { coordinates: [ [ -116.2023, 43.615 ], [ -122.3321, 47.6062 ] ] }.to_json
  end

  test "totals the route across all legs" do
    trip = build_trip("Denver", "Boise", "Seattle")
    trip.save!

    assert_equal 4_202_000.0, trip.route_distance
    assert_equal 144_000.0, trip.route_duration
  end

  test "only looks up the legs touching a changed stop" do
    trip = build_trip("Denver", "Boise", "Seattle")
    trip.save!
    assert_requested :post, OpenRouteService::URL, times: 2

    trip.update!(name: "Renamed Trip")
    assert_requested :post, OpenRouteService::URL, times: 2

    trip.update!(stops_attributes: [ { id: trip.stops.last.id, location: "Denver" } ])
    assert_requested :post, OpenRouteService::URL, times: 3
  end

  test "is invalid when there's no driving route" do
    stub_open_route_service_error(status: 404, error: { code: 2009, message: "Route could not be found" })
    trip = build_trip

    assert_not trip.valid?
    assert_includes trip.errors[:base], "There's no driving route from Denver to Seattle"
  end

  test "is invalid when a leg is too long to look up" do
    stub_open_route_service_error(status: 400, error: { code: 2004, message: "The approximated route distance must not be greater than 6000000.0 meters." })
    trip = build_trip

    assert_not trip.valid?
    assert_includes trip.errors[:base], "The drive from Denver to Seattle is too long for driving directions (the limit is about 3,700 miles)"
  end

  test "stops looking up legs after one fails" do
    stub_open_route_service_error(status: 403, error: "Access to this API has been disallowed")
    trip = build_trip("Denver", "Boise", "Seattle")

    assert_not trip.valid?
    assert_includes trip.errors[:base], "Driving directions couldn't be looked up right now, please try again"
    assert_requested :post, OpenRouteService::URL, times: 1
  end

  test "is invalid when the routing service times out" do
    stub_request(:post, OpenRouteService::URL).to_timeout
    trip = build_trip

    assert_not trip.valid?
    assert_includes trip.errors[:base], "Driving directions couldn't be looked up right now, please try again"
  end
end
