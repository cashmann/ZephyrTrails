class AddEndingLocationToTrips < ActiveRecord::Migration[8.1]
  def change
    add_column :trips, :ending_location, :string
  end
end
