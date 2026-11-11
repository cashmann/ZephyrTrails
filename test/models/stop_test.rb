require "test_helper"

class StopTest < ActiveSupport::TestCase
  setup do
    @trip = build_trip
    @trip.save!
  end

  test "geocodes its location" do
    assert_equal [ 39.7392, -104.9903 ], @trip.stops.first.coordinates
    assert_equal [ 47.6062, -122.3321 ], @trip.stops.last.coordinates
  end

  test "is invalid when its location can't be found" do
    stop = @trip.stops.build(position: 3, location: "Nowhereville")

    assert_not stop.valid?
    assert_includes stop.errors[:location], "couldn't be found. Check the spelling, or try a less specific address (e.g. just the city)"
  end

  test "is invalid when the geocoding service is unavailable" do
    stop = @trip.stops.build(position: 3, location: "Boise")

    original_search = Geocoder.method(:search)
    Geocoder.define_singleton_method(:search) { |*| raise Timeout::Error }
    begin
      assert_not stop.valid?
    ensure
      Geocoder.define_singleton_method(:search, original_search)
    end
    assert_includes stop.errors[:location], "couldn't be looked up right now, please try again"
  end

  test "trip stops are ordered by position" do
    @trip.stops.create!(position: 0, location: "Boise")

    assert_equal [ "Boise", "Denver", "Seattle" ], @trip.stops.reload.map(&:location)
  end

  test "requires a location and position" do
    stop = @trip.stops.build

    assert_not stop.valid?
    assert_includes stop.errors[:location], "can't be blank"
    assert_includes stop.errors[:position], "can't be blank"
  end

  test "is destroyed with its trip" do
    assert_difference("Stop.count", -2) { @trip.destroy }
  end
end
