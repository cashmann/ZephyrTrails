class AddRouteToTrips < ActiveRecord::Migration[8.1]
  def change
    add_column :trips, :route_distance, :float
    add_column :trips, :route_duration, :float
    add_column :trips, :route_geometry, :json
  end
end
