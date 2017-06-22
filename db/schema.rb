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

ActiveRecord::Schema.define(version: 20170614172358) do

  create_table "associated_budgets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "code"
    t.string  "name"
    t.string  "description"
    t.boolean "active"
  end

  create_table "auth_config_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "auth_configs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "auth_config_type_id"
    t.string   "name"
    t.string   "server"
    t.integer  "port"
    t.string   "ldap_base"
    t.string   "ldap_domain"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["auth_config_type_id"], name: "fk_config_type", using: :btree
  end

  create_table "budgeting_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "candidate_attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "notes"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "candidate_id"
    t.index ["candidate_id"], name: "fk_attachment_candidate", using: :btree
  end

  create_table "candidate_sources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "candidate_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "candidates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "candidate_status_id"
    t.integer  "candidate_source_id"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.date     "application_date"
    t.date     "first_contact_date"
    t.boolean  "is_referral"
    t.string   "referred_by"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
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
    t.text     "notes",                       limit: 65535
    t.integer  "office_location_id"
    t.integer  "gender_id"
    t.integer  "budgeting_type_id"
    t.string   "replacement_for"
    t.date     "rejection_call_request_date"
    t.string   "salary_range"
    t.integer  "sadness_factor"
    t.integer  "leave_reason_id"
    t.integer  "associated_budget_id"
    t.index ["associated_budget_id"], name: "fk_associated_budget", using: :btree
    t.index ["budgeting_type_id"], name: "fk_budgeting_type", using: :btree
    t.index ["candidate_source_id"], name: "fk_candidate_source", using: :btree
    t.index ["candidate_status_id"], name: "fk_candidate_status", using: :btree
    t.index ["education_level_id"], name: "fk_candidate_edu_lvl", using: :btree
    t.index ["experience_level_id"], name: "fk_candidate_exp_lvls", using: :btree
    t.index ["gender_id"], name: "fk_genders", using: :btree
    t.index ["leave_reason_id"], name: "fk_leave_reason", using: :btree
    t.index ["office_location_id"], name: "fk_candidate_off_loc", using: :btree
    t.index ["position_id"], name: "fk_candidate_position", using: :btree
    t.index ["school_id"], name: "fk_candidate_school", using: :btree
  end

  create_table "code_problems", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "code_submission_reviews", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "code_submission_id"
    t.integer  "user_id"
    t.text     "notes",              limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "review_result_id"
    t.index ["code_submission_id"], name: "fk_code_submission_review", using: :btree
    t.index ["review_result_id"], name: "fk_submission_rev_res", using: :btree
    t.index ["user_id"], name: "fk_code_submission_review_user", using: :btree
  end

  create_table "code_submissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "code_problem_id"
    t.integer  "candidate_id"
    t.date     "submission_date"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.date     "sent_date"
    t.text     "notes",           limit: 65535
    t.index ["candidate_id"], name: "fk_code_submission_candidate", using: :btree
    t.index ["code_problem_id"], name: "fk_code_submission_problem", using: :btree
  end

  create_table "education_levels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "code"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "experience_levels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.string "color"
  end

  create_table "genders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "interview_reviews", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id"
    t.integer  "interview_id"
    t.text     "notes",            limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "review_result_id"
    t.index ["interview_id"], name: "fk_interview_review_interview", using: :btree
    t.index ["review_result_id"], name: "fk_interview_rev_res", using: :btree
    t.index ["user_id"], name: "fk_interview_review_user", using: :btree
  end

  create_table "interview_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "interviews", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.date    "meeting_time"
    t.text    "notes",             limit: 65535
    t.integer "interview_type_id"
    t.integer "candidate_id"
    t.index ["candidate_id"], name: "fk_interview_candidate", using: :btree
    t.index ["interview_type_id"], name: "fk_interview_type", using: :btree
  end

  create_table "leave_reasons", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "office_locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "positions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "code"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "previous_employers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "reference_checks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "name"
    t.string  "email"
    t.string  "phone"
    t.text    "notes",            limit: 65535
    t.integer "candidate_id"
    t.integer "review_result_id"
    t.string  "title"
    t.string  "company"
    t.string  "relationship"
    t.integer "years_known"
    t.index ["candidate_id"], name: "fk_candidate", using: :btree
    t.index ["review_result_id"], name: "fk_ref_rev_res", using: :btree
  end

  create_table "registries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "review_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "code"
    t.string  "name"
    t.string  "description"
    t.boolean "is_approval"
    t.boolean "is_disapproval"
  end

  create_table "schools", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "code"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "admin"
    t.boolean  "active"
    t.string   "auth_name"
    t.string   "user_name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "auth_config_id"
    t.string   "password"
    t.string   "api_key"
    t.boolean  "manager"
    t.boolean  "hr"
    t.index ["auth_config_id"], name: "fk_auth_config", using: :btree
  end

  create_table "work_history_rows", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.date    "start_date"
    t.date    "end_date"
    t.integer "previous_employer_id"
    t.integer "candidate_id"
    t.index ["candidate_id"], name: "fk_history_candidate", using: :btree
    t.index ["previous_employer_id"], name: "fk_previous_employer", using: :btree
  end

  add_foreign_key "auth_configs", "auth_config_types", name: "fk_config_type"
  add_foreign_key "candidate_attachments", "candidates", name: "fk_attachment_candidate"
  add_foreign_key "candidates", "budgeting_types", name: "fk_budgeting_type"
  add_foreign_key "candidates", "genders", name: "fk_genders"
  add_foreign_key "candidates", "leave_reasons", name: "fk_leave_reason"
  add_foreign_key "users", "auth_configs", name: "fk_auth_config"
end
