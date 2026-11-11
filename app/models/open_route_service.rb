# Minimal client for the OpenRouteService directions API.
# https://openrouteservice.org/dev/#/api-docs/v2/directions/{profile}/geojson/post
module OpenRouteService
  URL = URI("https://api.openrouteservice.org/v2/directions/driving-car/geojson")
  NO_ROUTE_ERROR_CODES = [ 2009, 2010 ]
  ROUTE_TOO_LONG_ERROR_CODE = 2004

  class Error < StandardError; end
  class NoRouteError < Error; end
  class RouteTooLongError < Error; end

  Route = Data.define(:distance, :duration, :geometry)

  def self.driving_route(from, to)
    response = post(coordinates: [ from.reverse, to.reverse ])
    body = JSON.parse(response.body)

    raise_error(response, body) unless response.is_a?(Net::HTTPSuccess)
    parse_route(body)
  rescue JSON::ParserError, KeyError, Timeout::Error, SocketError, SystemCallError => e
    raise Error, "OpenRouteService request failed: #{e.class}: #{e.message}"
  end

  def self.post(payload)
    request = Net::HTTP::Post.new(URL, "Authorization" => api_key, "Content-Type" => "application/json")
    request.body = payload.to_json

    Net::HTTP.start(URL.host, URL.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.request(request)
    end
  end

  def self.api_key
    Rails.application.credentials.dig(:openrouteservice, :api_key).to_s
  end

  def self.raise_error(response, body)
    error = body["error"]
    code, message = error.is_a?(Hash) ? error.values_at("code", "message") : [ nil, error || response.message ]

    raise NoRouteError, message if NO_ROUTE_ERROR_CODES.include?(code)
    raise RouteTooLongError, message if code == ROUTE_TOO_LONG_ERROR_CODE
    raise Error, "OpenRouteService #{response.code}: #{message}"
  end

  def self.parse_route(body)
    feature = body.fetch("features").first
    summary = feature.dig("properties", "summary")

    Route.new(distance: summary.fetch("distance", 0), duration: summary.fetch("duration", 0), geometry: feature.dig("geometry", "coordinates"))
  end

  private_class_method :post, :api_key, :raise_error, :parse_route
end
