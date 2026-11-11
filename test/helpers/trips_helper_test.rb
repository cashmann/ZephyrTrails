require "test_helper"

class TripsHelperTest < ActionView::TestCase
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
