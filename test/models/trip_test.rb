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
end
