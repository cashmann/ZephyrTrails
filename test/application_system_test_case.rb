require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Block OpenStreetMap tiles so tests don't depend on (or load) an external
  # service. Leaflet still draws markers without them.
  driven_by :cuprite, screen_size: [ 1400, 1000 ], options: {
    url_blocklist: [ %r{tile\.openstreetmap\.org} ],
    js_errors: true
  }
end
