require "rate_limiter"
require "geocoder/lookups/nominatim"

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

# Geocoder doesn't throttle, so hold every uncached Nominatim request to the
# 1 request/second limit (per process; cache hits skip this).
module NominatimRateLimit
  LIMITER = RateLimiter.new(interval: 1.0)

  private

  def make_api_request(query)
    LIMITER.wait
    super
  end
end

Geocoder::Lookup::Nominatim.prepend(NominatimRateLimit)
