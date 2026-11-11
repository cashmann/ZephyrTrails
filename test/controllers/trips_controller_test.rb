require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  test "creates a trip and shows it" do
    assert_difference("Trip.count") do
      post trips_path, params: { trip: { name: "Road Trip", stops_attributes: {
        "0" => { position: 1, location: "Denver" },
        "1" => { position: 2, location: "Seattle" }
      } } }
    end

    follow_redirect!
    assert_response :success
    assert_select "h1", "Road Trip"
    assert_select "dd", "Denver"
    assert_select "dd", "Seattle"
    assert_select "dd", "1,306 mi - 20 hr 0 min"
    assert_select "[data-controller='trip-map']"
  end

  test "shows a stop's error next to its field" do
    assert_no_difference("Trip.count") do
      post trips_path, params: { trip: { name: "Road Trip", stops_attributes: {
        "0" => { position: 1, location: "Denver" },
        "1" => { position: 2, location: "" }
      } } }
    end

    assert_response :unprocessable_entity
    assert_select "#trip_stops_attributes_1_location.is-invalid"
    assert_select ".invalid-feedback", "Location can't be blank"
    assert_select ".alert-danger", count: 0
  end
end
