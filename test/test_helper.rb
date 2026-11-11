ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

# Only the app itself (and the browser driving system tests) may be reached over HTTP.
WebMock.disable_net_connect!(allow_localhost: true)

# Never hit a real geocoding service in tests; unknown addresses return no results.
Geocoder.configure(lookup: :test)
Geocoder::Lookup::Test.set_default_stub([])
Geocoder::Lookup::Test.add_stub("Denver", [ { "coordinates" => [ 39.7392, -104.9903 ] } ])
Geocoder::Lookup::Test.add_stub("Seattle", [ { "coordinates" => [ 47.6062, -122.3321 ] } ])
Geocoder::Lookup::Test.add_stub("Boise", [ { "coordinates" => [ 43.615, -116.2023 ] } ])

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Every trip save asks OpenRouteService for a route; answer with a short
    # two-point route unless a test stubs something else.
    setup do
      stub_open_route_service(distance: 2_101_000.0, duration: 72_000.0, geometry: [ [ -104.9903, 39.7392 ], [ -122.3321, 47.6062 ] ])
    end

    def build_trip(*locations, name: "Road Trip")
      locations = [ "Denver", "Seattle" ] if locations.empty?
      Trip.new(name:, stops_attributes: locations.map.with_index(1) { |location, position| { position:, location: } })
    end

    def stub_open_route_service(distance:, duration:, geometry:)
      stub_request(:post, OpenRouteService::URL).to_return(
        headers: { "Content-Type" => "application/json" },
        body: { type: "FeatureCollection", features: [ {
          type: "Feature",
          properties: { summary: { distance:, duration: } },
          geometry: { type: "LineString", coordinates: geometry }
        } ] }.to_json
      )
    end

    def stub_open_route_service_error(status:, error:)
      stub_request(:post, OpenRouteService::URL).to_return(status:, headers: { "Content-Type" => "application/json" }, body: { error: }.to_json)
    end
  end
end
