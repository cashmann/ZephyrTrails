module TripsHelper
  METERS_PER_MILE = 1609.344

  def trip_map_tag(trip)
    tag.div class: "trip-map rounded-3 mb-4", data: {
      controller: "trip-map",
      trip_map_stops_value: trip.stops.map { |stop| { lat: stop.latitude.to_f, lng: stop.longitude.to_f, label: stop.location } },
      trip_map_legs_value: trip.stops.drop(1).map(&:route_geometry)
    }
  end

  def format_route(meters, seconds)
    "#{format_route_distance(meters)} - #{format_route_duration(seconds)}"
  end

  def format_route_distance(meters)
    "#{number_with_delimiter((meters / METERS_PER_MILE).round)} mi"
  end

  def format_route_duration(seconds)
    hours, minutes = (seconds / 60.0).round.divmod(60)
    [ ("#{hours} hr" if hours > 0), "#{minutes} min" ].compact.join(" ")
  end
end
