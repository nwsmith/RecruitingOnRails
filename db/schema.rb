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

ActiveRecord::Schema.define(:version => 20150930151335) do

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
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "experience_level_id"
    t.integer  "position_id"
    t.integer  "school_id"
    t.integer  "education_level_id"
    t.date     "offer_date"
    t.date     "offer_accept_date"
    t.date     "offer_turndown_date"
    t.date     "start_date"
    t.date     "fire_date"
    t.date     "quit_date"
    t.date     "end_date"
    t.date     "rejection_notification_date"
    t.text     "notes"
    t.integer  "office_location_id"
    t.integer  "genders_id"
  end

  add_index "candidates", ["candidate_source_id"], :name => "fk_candidate_source"
  add_index "candidates", ["candidate_status_id"], :name => "fk_candidate_status"
  add_index "candidates", ["education_level_id"], :name => "fk_candidate_edu_lvl"
  add_index "candidates", ["experience_level_id"], :name => "fk_candidate_exp_lvls"
  add_index "candidates", ["genders_id"], :name => "fk_genders"
  add_index "candidates", ["office_location_id"], :name => "fk_candidate_off_loc"
  add_index "candidates", ["position_id"], :name => "fk_candidate_position"
  add_index "candidates", ["school_id"], :name => "fk_candidate_school"

  create_table "code_problems", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "code_submission_reviews", :force => true do |t|
    t.integer  "code_submission_id"
    t.integer  "user_id"
    t.text     "notes"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "review_result_id"
  end

  add_index "code_submission_reviews", ["code_submission_id"], :name => "fk_code_submission_review"
  add_index "code_submission_reviews", ["review_result_id"], :name => "fk_submission_rev_res"
  add_index "code_submission_reviews", ["user_id"], :name => "fk_code_submission_review_user"

  create_table "code_submissions", :force => true do |t|
    t.integer  "code_problem_id"
    t.integer  "candidate_id"
    t.date     "submission_date"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.date     "sent_date"
    t.text     "notes"
  end

  add_index "code_submissions", ["candidate_id"], :name => "fk_code_submission_candidate"
  add_index "code_submissions", ["code_problem_id"], :name => "fk_code_submission_problem"

  create_table "education_levels", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "experience_levels", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.string "color"
  end

  create_table "genders", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

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

  create_table "interview_reviews", :force => true do |t|
    t.integer  "user_id"
    t.integer  "interview_id"
    t.text     "notes"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "review_result_id"
  end

  add_index "interview_reviews", ["interview_id"], :name => "fk_interview_review_interview"
  add_index "interview_reviews", ["review_result_id"], :name => "fk_interview_rev_res"
  add_index "interview_reviews", ["user_id"], :name => "fk_interview_review_user"

  create_table "interview_types", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "interviews", :force => true do |t|
    t.datetime "meeting_time"
    t.text     "notes"
    t.integer  "interview_type_id"
    t.integer  "candidate_id"
  end

  add_index "interviews", ["candidate_id"], :name => "fk_interview_candidate"
  add_index "interviews", ["interview_type_id"], :name => "fk_interview_type"

  create_table "office_locations", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "positions", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "previous_employers", :force => true do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "reference_checks", :force => true do |t|
    t.string  "name"
    t.string  "email"
    t.string  "phone"
    t.text    "notes"
    t.integer "candidate_id"
    t.integer "review_result_id"
    t.string  "title"
    t.string  "company"
    t.string  "relationship"
    t.integer "years_known"
  end

  add_index "reference_checks", ["candidate_id"], :name => "fk_candidate"
  add_index "reference_checks", ["review_result_id"], :name => "fk_ref_rev_res"

  create_table "registries", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "review_results", :force => true do |t|
    t.string  "code"
    t.string  "name"
    t.string  "description"
    t.boolean "is_approval"
    t.boolean "is_disapproval"
  end

  create_table "schools", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
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

  create_table "work_history_rows", :force => true do |t|
    t.date    "start_date"
    t.date    "end_date"
    t.integer "previous_employer_id"
    t.integer "candidate_id"
  end

  add_index "work_history_rows", ["candidate_id"], :name => "fk_history_candidate"
  add_index "work_history_rows", ["previous_employer_id"], :name => "fk_previous_employer"

end
