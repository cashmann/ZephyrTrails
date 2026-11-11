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

  test "adding and removing stops along the way" do
    visit root_path

    fill_in "Trip Name", with: "Road Trip"
    fill_in "Starting Location", with: "Denver"
    fill_in "Ending Location", with: "Seattle"

    click_on "+ Add a stop"
    click_on "+ Add a stop"
    stop_fields = all(".stop-field input", minimum: 4)
    stop_fields[1].fill_in with: "Boise"
    stop_fields[2].fill_in with: "Nowhereville"
    all("button[aria-label='Remove stop']").last.click

    click_on "Let's Go!"

    assert_text "Trip created!"
    assert_equal [ "Denver", "Boise", "Seattle" ], all(".trip-itinerary-stop").map(&:text)
  end

  test "a stop that can't be found shows its error under the field" do
    visit root_path

    fill_in "Trip Name", with: "Road Trip"
    fill_in "Starting Location", with: "Denver"
    click_on "+ Add a stop"
    all(".stop-field input", minimum: 3)[1].fill_in with: "Nowhereville"
    fill_in "Ending Location", with: "Seattle"
    click_on "Let's Go!"

    assert_text "Location couldn't be found"
    assert_field with: "Nowhereville", class: "is-invalid"
  end

  test "a trip with several stops shows each leg and stop on the map" do
    trip = build_trip("Denver", "Boise", "Seattle")
    trip.save!

    visit trip_path(trip)

    within ".trip-map.leaflet-container" do
      # Two route lines plus three stop markers
      assert_selector "path.leaflet-interactive", count: 5
    end
  end
end
