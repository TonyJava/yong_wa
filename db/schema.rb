# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150817060253) do

  create_table "admin_manage_users", force: :cascade do |t|
    t.string   "user_name",  limit: 255
    t.string   "password",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "devices", force: :cascade do |t|
    t.string   "series_code",   limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "sex",           limit: 255
    t.string   "birth",         limit: 255
    t.string   "height",        limit: 255
    t.string   "weight",        limit: 255
    t.string   "mobile",        limit: 255
    t.string   "imei",          limit: 255
    t.string   "device_name",   limit: 255
    t.boolean  "active",        limit: 1
    t.text     "config_info",   limit: 65535
    t.text     "tracking_info", limit: 65535
  end

  create_table "histories", force: :cascade do |t|
    t.integer  "data_type",          limit: 4
    t.string   "data_content",       limit: 255
    t.string   "location_code",      limit: 255
    t.string   "location_type",      limit: 255
    t.string   "data_stamp_address", limit: 255
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "device_id",          limit: 4
    t.decimal  "lng",                            precision: 9, scale: 6
    t.decimal  "lat",                            precision: 9, scale: 6
  end

  add_index "histories", ["device_id"], name: "index_histories_on_device_id", using: :btree

  create_table "user_devices", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "device_id",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_devices", ["device_id"], name: "index_user_devices_on_device_id", using: :btree
  add_index "user_devices", ["user_id"], name: "index_user_devices_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "mobile",     limit: 255
    t.string   "password",   limit: 255
    t.string   "auth_token", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "histories", "devices"
  add_foreign_key "user_devices", "devices"
  add_foreign_key "user_devices", "users"
end
