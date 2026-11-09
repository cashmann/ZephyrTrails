require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  test "creates a trip and shows it" do
    assert_difference("Trip.count") do
      post trips_path, params: { trip: { name: "Road Trip", starting_location: "Denver", ending_location: "Seattle" } }
    end

    follow_redirect!
    assert_response :success
    assert_select "h1", "Road Trip"
    assert_select "dd", "Denver"
    assert_select "dd", "Seattle"
  end

  test "requires an ending location" do
    assert_no_difference("Trip.count") do
      post trips_path, params: { trip: { name: "Road Trip", starting_location: "Denver" } }
    end

    assert_response :unprocessable_entity
    assert_select "li", "Ending location can't be blank"
  end
end
