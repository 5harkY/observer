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

ActiveRecord::Schema[7.0].define(version: 2023_02_12_124848) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ip_addresses", force: :cascade do |t|
    t.inet "address", null: false
    t.datetime "created_at", null: false
    t.index ["address"], name: "index_ip_addresses_on_address", unique: true
  end

  create_table "observation_results", force: :cascade do |t|
    t.bigint "ip_address_id", null: false
    t.float "rtt"
    t.boolean "success", null: false
    t.datetime "created_at", null: false
    t.index ["ip_address_id"], name: "index_observation_results_on_ip_address_id"
  end

  create_table "observations", force: :cascade do |t|
    t.bigint "ip_address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "stopped_at"
    t.index ["ip_address_id"], name: "index_observations_on_ip_address_id"
  end

end
