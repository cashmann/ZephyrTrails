require "application_system_test_case"

class TripsTest < ApplicationSystemTestCase
  test "creating a trip shows its start and end on a map" do
    visit root_path

    fill_in "Trip Name", with: "Road Trip"
    fill_in "Starting Location", with: "Denver"
    fill_in "Ending Location", with: "Seattle"
    click_on "Let's Go!"

    assert_text "Trip created!"
    assert_text "1,306 mi - 20 hr 0 min"
    within ".trip-map.leaflet-container" do
      # The route line plus the start and end markers
      assert_selector "path.leaflet-interactive", count: 3
    end
  end
end
