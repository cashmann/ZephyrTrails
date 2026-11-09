# Nominatim (OpenStreetMap) needs no API key, but its usage policy requires an
# identifying User-Agent and allows at most 1 request per second.
# https://operations.osmfoundation.org/policies/nominatim/
Geocoder.configure(
  lookup: :nominatim,
  timeout: 5,
  http_headers: { "User-Agent" => "ZephyrTrails" },
  cache: Rails.cache,
  cache_options: { expiration: 1.day },
  always_raise: :all
)
