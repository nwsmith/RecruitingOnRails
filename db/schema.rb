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

ActiveRecord::Schema[7.0].define(version: 2017_07_19_000343) do
  create_table "associated_budgets", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.boolean "active"
  end

  create_table "auth_config_types", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "auth_configs", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "auth_config_type_id"
    t.string "name"
    t.string "server"
    t.integer "port"
    t.string "ldap_base"
    t.string "ldap_domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_config_type_id"], name: "index_auth_configs_on_auth_config_type_id"
  end

  create_table "budgeting_types", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "candidate_attachments", charset: "utf8mb3", force: :cascade do |t|
    t.string "notes"
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.bigint "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.bigint "candidate_id"
    t.index ["candidate_id"], name: "index_candidate_attachments_on_candidate_id"
  end

  create_table "candidate_sources", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "candidate_statuses", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "candidates", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "candidate_status_id"
    t.bigint "candidate_source_id"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.date "application_date"
    t.date "first_contact_date"
    t.boolean "is_referral"
    t.string "referred_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "experience_level_id"
    t.bigint "position_id"
    t.bigint "school_id"
    t.bigint "education_level_id"
    t.date "offer_date"
    t.date "offer_accept_date"
    t.date "offer_turndown_date"
    t.date "start_date"
    t.date "fire_date"
    t.date "quit_date"
    t.date "end_date"
    t.date "rejection_notification_date"
    t.text "notes"
    t.bigint "office_location_id"
    t.bigint "gender_id"
    t.bigint "budgeting_type_id"
    t.string "replacement_for"
    t.date "rejection_call_request_date"
    t.string "salary_range"
    t.integer "sadness_factor"
    t.bigint "leave_reason_id"
    t.bigint "associated_budget_id"
    t.index ["associated_budget_id"], name: "index_candidates_on_associated_budget_id"
    t.index ["budgeting_type_id"], name: "index_candidates_on_budgeting_type_id"
    t.index ["candidate_source_id"], name: "index_candidates_on_candidate_source_id"
    t.index ["candidate_status_id"], name: "index_candidates_on_candidate_status_id"
    t.index ["education_level_id"], name: "index_candidates_on_education_level_id"
    t.index ["experience_level_id"], name: "index_candidates_on_experience_level_id"
    t.index ["gender_id"], name: "index_candidates_on_gender_id"
    t.index ["leave_reason_id"], name: "index_candidates_on_leave_reason_id"
    t.index ["office_location_id"], name: "index_candidates_on_office_location_id"
    t.index ["position_id"], name: "index_candidates_on_position_id"
    t.index ["school_id"], name: "index_candidates_on_school_id"
  end

  create_table "code_problems", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "code_submission_reviews", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "code_submission_id"
    t.bigint "user_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "review_result_id"
    t.index ["code_submission_id"], name: "index_code_submission_reviews_on_code_submission_id"
    t.index ["review_result_id"], name: "index_code_submission_reviews_on_review_result_id"
    t.index ["user_id"], name: "index_code_submission_reviews_on_user_id"
  end

  create_table "code_submissions", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "code_problem_id"
    t.bigint "candidate_id"
    t.date "submission_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "sent_date"
    t.text "notes"
    t.index ["candidate_id"], name: "index_code_submissions_on_candidate_id"
    t.index ["code_problem_id"], name: "index_code_submissions_on_code_problem_id"
  end

  create_table "diary_entries", charset: "utf8mb3", force: :cascade do |t|
    t.date "entry_date"
    t.text "notes"
    t.bigint "candidate_id"
    t.bigint "diary_entry_type_id"
    t.bigint "user_id"
    t.index ["candidate_id"], name: "index_diary_entries_on_candidate_id"
    t.index ["diary_entry_type_id"], name: "index_diary_entries_on_diary_entry_type_id"
    t.index ["user_id"], name: "index_diary_entries_on_user_id"
  end

  create_table "diary_entry_types", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.boolean "positive"
    t.boolean "negative"
  end

  create_table "education_levels", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "experience_levels", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.string "color"
  end

  create_table "genders", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "groups", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups_users", id: false, charset: "utf8mb3", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "interview_reviews", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "interview_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "review_result_id"
    t.index ["interview_id"], name: "index_interview_reviews_on_interview_id"
    t.index ["review_result_id"], name: "index_interview_reviews_on_review_result_id"
    t.index ["user_id"], name: "index_interview_reviews_on_user_id"
  end

  create_table "interview_types", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "interviews", charset: "utf8mb3", force: :cascade do |t|
    t.date "meeting_time"
    t.text "notes"
    t.bigint "interview_type_id"
    t.bigint "candidate_id"
    t.index ["candidate_id"], name: "index_interviews_on_candidate_id"
    t.index ["interview_type_id"], name: "index_interviews_on_interview_type_id"
  end

  create_table "leave_reasons", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "office_locations", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "positions", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "previous_employers", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
  end

  create_table "reference_checks", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.text "notes"
    t.bigint "candidate_id"
    t.bigint "review_result_id"
    t.string "title"
    t.string "company"
    t.string "relationship"
    t.integer "years_known"
    t.index ["candidate_id"], name: "index_reference_checks_on_candidate_id"
    t.index ["review_result_id"], name: "index_reference_checks_on_review_result_id"
  end

  create_table "registries", charset: "utf8mb3", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "review_results", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.boolean "is_approval"
    t.boolean "is_disapproval"
  end

  create_table "schools", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.boolean "admin"
    t.boolean "active"
    t.string "auth_name"
    t.string "user_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "auth_config_id"
    t.string "password"
    t.string "api_key"
    t.boolean "manager"
    t.boolean "hr"
    t.index ["auth_config_id"], name: "index_users_on_auth_config_id"
  end

  create_table "work_history_rows", charset: "utf8mb3", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.bigint "previous_employer_id"
    t.bigint "candidate_id"
    t.index ["candidate_id"], name: "index_work_history_rows_on_candidate_id"
    t.index ["previous_employer_id"], name: "index_work_history_rows_on_previous_employer_id"
  end

  add_foreign_key "auth_configs", "auth_config_types", name: "fk_config_type"
  add_foreign_key "candidate_attachments", "candidates", name: "fk_attachment_candidate"
  add_foreign_key "candidates", "associated_budgets", name: "fk_associated_budget"
  add_foreign_key "candidates", "budgeting_types", name: "fk_budgeting_type"
  add_foreign_key "candidates", "candidate_sources", name: "fk_candidate_source"
  add_foreign_key "candidates", "candidate_statuses", name: "fk_candidate_status"
  add_foreign_key "candidates", "education_levels", name: "fk_candidate_edu_lvl"
  add_foreign_key "candidates", "experience_levels", name: "fk_candidate_exp_lvls"
  add_foreign_key "candidates", "genders", name: "fk_genders"
  add_foreign_key "candidates", "leave_reasons", name: "fk_leave_reason"
  add_foreign_key "candidates", "office_locations", name: "fk_candidate_off_loc"
  add_foreign_key "candidates", "positions", name: "fk_candidate_position"
  add_foreign_key "candidates", "schools", name: "fk_candidate_school"
  add_foreign_key "code_submission_reviews", "code_submissions", name: "fk_code_submission_review"
  add_foreign_key "code_submission_reviews", "review_results", name: "fk_submission_rev_res"
  add_foreign_key "code_submission_reviews", "users", name: "fk_code_submission_review_user"
  add_foreign_key "code_submissions", "candidates", name: "fk_code_submission_candidate"
  add_foreign_key "code_submissions", "code_problems", name: "fk_code_submission_problem"
  add_foreign_key "diary_entries", "candidates"
  add_foreign_key "diary_entries", "diary_entry_types"
  add_foreign_key "diary_entries", "users"
  add_foreign_key "interview_reviews", "interviews", name: "fk_interview_review_interview"
  add_foreign_key "interview_reviews", "review_results", name: "fk_interview_rev_res"
  add_foreign_key "interview_reviews", "users", name: "fk_interview_review_user"
  add_foreign_key "interviews", "candidates", name: "fk_interview_candidate"
  add_foreign_key "interviews", "interview_types", name: "fk_interview_type"
  add_foreign_key "reference_checks", "candidates", name: "fk_candidate"
  add_foreign_key "reference_checks", "review_results", name: "fk_ref_rev_res"
  add_foreign_key "users", "auth_configs", name: "fk_auth_config"
  add_foreign_key "work_history_rows", "candidates", name: "fk_history_candidate"
  add_foreign_key "work_history_rows", "previous_employers", name: "fk_previous_employer"
end
