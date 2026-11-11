require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  test "creates a trip and shows it" do
    assert_difference("Trip.count") do
      post trips_path, params: { trip: { name: "Road Trip", stops_attributes: {
        "0" => { location: "Denver" },
        "1" => { location: "Seattle" }
      } } }
    end

    follow_redirect!
    assert_response :success
    assert_select "h1", "Road Trip"
    assert_select ".trip-itinerary-stop.is-start", "Denver"
    assert_select ".trip-itinerary-stop.is-end", "Seattle"
    assert_select "[data-controller='trip-map']"
  end

  test "shows every stop with the drive of each leg" do
    trip = build_trip("Denver", "Boise", "Seattle")
    trip.save!

    get trip_path(trip)

    assert_select ".trip-itinerary-stop", count: 3 do |stops|
      assert_equal [ "Denver", "Boise", "Seattle" ], stops.map(&:text)
    end
    assert_select ".trip-itinerary-leg", count: 2, text: "1,306 mi - 20 hr 0 min"
    assert_select "dd", "2,611 mi - 40 hr 0 min"
  end

  test "creates a trip with stops in the order they appear in the form" do
    post trips_path, params: { trip: { name: "Road Trip", stops_attributes: {
      "0" => { location: "Denver" },
      "1731000000000" => { location: "Boise" },
      "1" => { location: "Seattle" }
    } } }

    assert_equal [ "Denver", "Boise", "Seattle" ], Trip.last.stops.map(&:location)
  end

  test "keeps added stops in the form when it has errors" do
    post trips_path, params: { trip: { name: "Road Trip", stops_attributes: {
      "0" => { location: "Denver" },
      "1731000000000" => { location: "Nowhereville" },
      "1" => { location: "Seattle" }
    } } }

    assert_response :unprocessable_entity
    assert_select "[data-controller='stop-fields'] > .stop-field", count: 3
    assert_select "[data-controller='stop-fields'] > .stop-field input.is-invalid[value='Nowhereville']"
    assert_select "[data-controller='stop-fields'] > .stop-field button[aria-label='Remove stop']", count: 1
  end

  test "shows a stop's error next to its field" do
    assert_no_difference("Trip.count") do
      post trips_path, params: { trip: { name: "Road Trip", stops_attributes: {
        "0" => { location: "Denver" },
        "1" => { location: "" }
      } } }
    end

    assert_response :unprocessable_entity
    assert_select "#trip_stops_attributes_1_location.is-invalid + .invalid-feedback"
    assert_select ".field_with_errors", count: 0
    assert_select ".invalid-feedback", "Location can't be blank"
    assert_select ".alert-danger", count: 0
  end
end
