class MoveLocationsAndRoutesToStops < ActiveRecord::Migration[8.1]
  def up
    # Each stop stores the route of the leg arriving at it (the first stop has none).
    add_column :stops, :route_distance, :float
    add_column :stops, :route_duration, :float
    add_column :stops, :route_geometry, :json

    execute <<~SQL
      UPDATE stops SET
        route_distance = (SELECT route_distance FROM trips WHERE trips.id = stops.trip_id),
        route_duration = (SELECT route_duration FROM trips WHERE trips.id = stops.trip_id),
        route_geometry = (SELECT route_geometry FROM trips WHERE trips.id = stops.trip_id)
      WHERE position = 2
    SQL

    remove_columns :trips,
      :starting_location, :starting_latitude, :starting_longitude,
      :ending_location, :ending_latitude, :ending_longitude,
      :route_distance, :route_duration, :route_geometry
  end

  def down
    add_column :trips, :starting_location, :string
    add_column :trips, :starting_latitude, :decimal, precision: 10, scale: 6
    add_column :trips, :starting_longitude, :decimal, precision: 10, scale: 6
    add_column :trips, :ending_location, :string
    add_column :trips, :ending_latitude, :decimal, precision: 10, scale: 6
    add_column :trips, :ending_longitude, :decimal, precision: 10, scale: 6
    add_column :trips, :route_distance, :float
    add_column :trips, :route_duration, :float
    add_column :trips, :route_geometry, :json

    execute <<~SQL
      UPDATE trips SET
        starting_location = (SELECT location FROM stops WHERE stops.trip_id = trips.id AND position = 1),
        starting_latitude = (SELECT latitude FROM stops WHERE stops.trip_id = trips.id AND position = 1),
        starting_longitude = (SELECT longitude FROM stops WHERE stops.trip_id = trips.id AND position = 1),
        ending_location = (SELECT location FROM stops WHERE stops.trip_id = trips.id AND position = 2),
        ending_latitude = (SELECT latitude FROM stops WHERE stops.trip_id = trips.id AND position = 2),
        ending_longitude = (SELECT longitude FROM stops WHERE stops.trip_id = trips.id AND position = 2),
        route_distance = (SELECT route_distance FROM stops WHERE stops.trip_id = trips.id AND position = 2),
        route_duration = (SELECT route_duration FROM stops WHERE stops.trip_id = trips.id AND position = 2),
        route_geometry = (SELECT route_geometry FROM stops WHERE stops.trip_id = trips.id AND position = 2)
    SQL

    remove_columns :stops, :route_distance, :route_duration, :route_geometry
  end
end
