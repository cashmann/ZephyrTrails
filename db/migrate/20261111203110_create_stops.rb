class CreateStops < ActiveRecord::Migration[8.1]
  def change
    create_table :stops do |t|
      t.references :trip, null: false, foreign_key: true, index: false
      t.integer :position, null: false
      t.string :location, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false

      t.timestamps
    end
    add_index :stops, [ :trip_id, :position ]
  end
end
