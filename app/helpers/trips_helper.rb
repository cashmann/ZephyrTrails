module TripsHelper
  METERS_PER_MILE = 1609.344

  def trip_map_tag(trip)
    tag.div class: "trip-map rounded-3 mb-4", data: {
      controller: "trip-map",
      trip_map_stops_value: trip.stops.map { |stop| { lat: stop.latitude.to_f, lng: stop.longitude.to_f, label: stop.location } },
      trip_map_legs_value: trip.stops.drop(1).map(&:route_geometry)
    }
  end

  def stop_field_options(trip, stop)
    case stop
    when trip.starting_stop
      { label_text: "Starting Location", placeholder: "Where does it begin?", removable: false }
    when trip.ending_stop
      { label_text: "Ending Location", placeholder: "Where does it end?", removable: false }
    else
      intermediate_stop_field_options
    end
  end

  def intermediate_stop_field_options
    { label_text: "Stop Along the Way", placeholder: "Where else are you headed?", removable: true }
  end

  def format_trip_dates(trip)
    return unless trip.start_date || trip.end_date

    [ trip.start_date, trip.end_date ].map { |date| date&.to_date&.to_fs(:long) || "?" }.join(" – ")
  end

  def format_stopovers(trip)
    stopovers = trip.stops.size - 2
    "via #{pluralize(stopovers, "stop")}" if stopovers > 0
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
