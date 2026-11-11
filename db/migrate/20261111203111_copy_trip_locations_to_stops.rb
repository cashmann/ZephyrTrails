class CopyTripLocationsToStops < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      INSERT INTO stops (trip_id, position, location, latitude, longitude, created_at, updated_at)
      SELECT id, 1, starting_location, starting_latitude, starting_longitude, created_at, updated_at FROM trips
      UNION ALL
      SELECT id, 2, ending_location, ending_latitude, ending_longitude, created_at, updated_at FROM trips
    SQL
  end

  def down
    execute "DELETE FROM stops"
  end
end
