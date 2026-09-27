class AddTripsTable < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.string :name
      t.string :starting_location
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
