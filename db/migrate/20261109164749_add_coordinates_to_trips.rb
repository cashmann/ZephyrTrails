class AddCoordinatesToTrips < ActiveRecord::Migration[8.1]
  def change
    add_column :trips, :starting_latitude, :decimal, precision: 10, scale: 6
    add_column :trips, :starting_longitude, :decimal, precision: 10, scale: 6
    add_column :trips, :ending_latitude, :decimal, precision: 10, scale: 6
    add_column :trips, :ending_longitude, :decimal, precision: 10, scale: 6
  end
end
