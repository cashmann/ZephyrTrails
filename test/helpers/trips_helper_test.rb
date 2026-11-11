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

  test "formats a trip's dates" do
    assert_equal "November 09, 2026 – November 12, 2026", format_trip_dates(Trip.new(start_date: "2026-11-09", end_date: "2026-11-12"))
    assert_equal "November 09, 2026 – ?", format_trip_dates(Trip.new(start_date: "2026-11-09"))
    assert_nil format_trip_dates(Trip.new)
  end

  test "describes the stops between start and end" do
    assert_nil format_stopovers(build_trip("Denver", "Seattle"))
    assert_equal "via 1 stop", format_stopovers(build_trip("Denver", "Boise", "Seattle"))
    assert_equal "via 2 stops", format_stopovers(build_trip("Denver", "Boise", "Boise", "Seattle"))
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
