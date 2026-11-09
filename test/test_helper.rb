ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Never hit a real geocoding service in tests; unknown addresses return no results.
Geocoder.configure(lookup: :test)
Geocoder::Lookup::Test.set_default_stub([])
Geocoder::Lookup::Test.add_stub("Denver", [ { "coordinates" => [ 39.7392, -104.9903 ] } ])
Geocoder::Lookup::Test.add_stub("Seattle", [ { "coordinates" => [ 47.6062, -122.3321 ] } ])

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
