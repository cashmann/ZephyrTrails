require "test_helper"

class TripsHelperTest < ActionView::TestCase
  test "renders a map of the trip's stops and legs" do
    trip = build_trip("Denver", "Boise", "Seattle")
    trip.save!

    map = Nokogiri::HTML5.fragment(trip_map_tag(trip)).at("div")

    assert_equal "trip-map", map["data-controller"]
    assert_equal [ "Denver", "Boise", "Seattle" ], JSON.parse(map["data-trip-map-stops-value"]).map { |stop| stop["label"] }
    assert_equal 2, JSON.parse(map["data-trip-map-legs-value"]).size
  end

  test "formats a route as distance and duration" do
    assert_equal "1,306 mi - 20 hr 0 min", format_route(2_101_000, 72_000)
  end

  test "formats route distance in miles" do
    assert_equal "1,306 mi", format_route_distance(2_101_000)
    assert_equal "0 mi", format_route_distance(0)
  end

  test "formats route duration in hours and minutes" do
    assert_equal "20 hr 0 min", format_route_duration(72_000)
    assert_equal "1 hr 35 min", format_route_duration(5_700)
    assert_equal "45 min", format_route_duration(2_700)
  end
end
