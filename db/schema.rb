# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_09_173902) do
  create_table "trips", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_date"
    t.decimal "ending_latitude", precision: 10, scale: 6
    t.string "ending_location"
    t.decimal "ending_longitude", precision: 10, scale: 6
    t.string "name"
    t.float "route_distance"
    t.float "route_duration"
    t.json "route_geometry"
    t.datetime "start_date"
    t.decimal "starting_latitude", precision: 10, scale: 6
    t.string "starting_location"
    t.decimal "starting_longitude", precision: 10, scale: 6
    t.datetime "updated_at", null: false
  end
end
