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

ActiveRecord::Schema.define(:version => 20120323171638) do

  create_table "candidate_sources", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "candidate_statuses", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "candidates", :force => true do |t|
    t.integer  "candidate_status_id"
    t.integer  "candidate_source_id"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.date     "application_date"
    t.date     "first_contact_date"
    t.boolean  "is_referral"
    t.string   "referred_by"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "candidates", ["candidate_source_id"], :name => "fk_candidate_source"
  add_index "candidates", ["candidate_status_id"], :name => "fk_candidate_status"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.boolean  "active"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "admin"
    t.boolean  "active"
    t.string   "auth_name"
    t.string   "user_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
