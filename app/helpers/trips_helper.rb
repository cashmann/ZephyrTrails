module TripsHelper
  METERS_PER_MILE = 1609.344

  def format_route_distance(meters)
    "#{number_with_delimiter((meters / METERS_PER_MILE).round)} mi"
  end

  def format_route_duration(seconds)
    hours, minutes = (seconds / 60.0).round.divmod(60)
    [ ("#{hours} hr" if hours > 0), "#{minutes} min" ].compact.join(" ")
  end
end
