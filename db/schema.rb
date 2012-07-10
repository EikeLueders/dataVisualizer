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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120710141144) do

  create_table "approx10_min_measured_data", :force => true do |t|
    t.integer  "project_id"
    t.datetime "date"
    t.decimal  "value"
    t.decimal  "aggregated_value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "approx10_min_measured_data", ["project_id"], :name => "index_approx10_min_measured_data_on_project_id"

  create_table "approx1_day_measured_data", :force => true do |t|
    t.integer  "project_id"
    t.datetime "date"
    t.decimal  "value"
    t.decimal  "aggregated_value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "approx1_day_measured_data", ["project_id"], :name => "index_approx1_day_measured_data_on_project_id"

  create_table "approximated_measured_data", :force => true do |t|
    t.integer  "project_id"
    t.integer  "resolution"
    t.decimal  "value"
    t.datetime "date"
    t.decimal  "aggregated_value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "approximated_measured_data", ["project_id"], :name => "index_approximated_measured_data_on_project_id"

  create_table "measured_data", :force => true do |t|
    t.integer  "project_id"
    t.datetime "date"
    t.decimal  "value"
    t.decimal  "aggregated_value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "measured_data", ["project_id"], :name => "index_measured_data_on_project_id"

  create_table "measured_datum10_mins", :force => true do |t|
    t.integer  "project_id"
    t.datetime "date"
    t.decimal  "value"
    t.decimal  "aggregated_value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "measured_datum10_mins", ["project_id"], :name => "index_measured_datum10_mins_on_project_id"

  create_table "measured_datum1_days", :force => true do |t|
    t.integer  "project_id"
    t.datetime "date"
    t.decimal  "value"
    t.decimal  "aggregated_value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "measured_datum1_days", ["project_id"], :name => "index_measured_datum1_days_on_project_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.decimal  "factor"
    t.string   "unit"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "projects", ["user_id"], :name => "index_projects_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
