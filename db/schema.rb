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

ActiveRecord::Schema.define(version: 20151222061239) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "affiliations", force: :cascade do |t|
    t.string   "organization"
    t.string   "job_title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "veteran_id",   index: {name: "index_affiliations_on_veteran_id"}
  end

  create_table "awards", force: :cascade do |t|
    t.string   "title"
    t.string   "organization"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "veteran_id",   index: {name: "index_awards_on_veteran_id"}
    t.date     "date"
  end

  create_table "deprecated_job_skill_matches", force: :cascade do |t|
    t.integer  "matchable_id",            index: {name: "index_deprecated_job_skill_matches_on_matchable_id_and_matchabl", with: ["matchable_type"]}
    t.string   "matchable_type"
    t.integer  "deprecated_job_skill_id", index: {name: "index_deprecated_job_skill_matches_on_deprecated_job_skill_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deprecated_job_skills", force: :cascade do |t|
    t.string   "code",        index: {name: "index_deprecated_job_skills_on_code"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "source"
    t.text     "description"
  end

  create_table "employers", force: :cascade do |t|
    t.string   "company_name"
    t.string   "ein"
    t.boolean  "approved",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",               index: {name: "index_employers_on_user_id"}
    t.date     "commit_date"
    t.integer  "commit_to_hire",        index: {name: "index_employers_on_commit_to_hire"}
    t.integer  "commit_hired"
    t.string   "website"
    t.string   "location"
    t.string   "note"
    t.string   "phone"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "commitment_categories", default: "--- []\n"
    t.string   "admin_notes"
    t.string   "approved_by"
    t.date     "approved_on"
    t.text     "job_postings_url"
    t.string   "poc_name"
    t.string   "poc_email"
  end

  create_table "experiences", force: :cascade do |t|
    t.string   "experience_type"
    t.string   "job_title"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "organization"
    t.string   "educational_organization"
    t.string   "credential_type",          index: {name: "index_experiences_on_credential_type"}
    t.string   "credential_topic"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "veteran_id",               index: {name: "index_experiences_on_veteran_id"}
    t.string   "moc",                      index: {name: "index_experiences_on_moc"}
    t.string   "duty_station"
    t.string   "hours"
    t.string   "rank"
  end

  create_table "favorite_veterans", force: :cascade do |t|
    t.integer  "veteran_id"
    t.integer  "employer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_title_military_occupations", force: :cascade do |t|
    t.integer  "job_title_id",           index: {name: "index_job_title_military_occupations_on_job_title_id"}
    t.integer  "military_occupation_id", index: {name: "index_job_title_military_occupations_on_military_occupation_id"}
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "preparation_needed"
    t.string   "pay_grade",              index: {name: "index_job_title_military_occupations_on_pay_grade"}
    t.string   "match_type"
  end

  create_table "job_titles", force: :cascade do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.string   "source"
    t.string   "url"
    t.boolean  "has_bright_outlook"
    t.boolean  "is_green"
    t.boolean  "has_apprenticeship"
  end

  create_table "locations", force: :cascade do |t|
    t.integer  "veteran_id",     index: {name: "index_locations_on_veteran_id"}
    t.string   "location_type"
    t.string   "full_name",      index: {name: "index_locations_on_full_name_and_location_type", with: ["location_type"]}
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.string   "country"
    t.decimal  "lat",            precision: 10, scale: 6, index: {name: "index_locations_on_lat_and_lng", with: ["lng"]}
    t.decimal  "lng",            precision: 10, scale: 6
    t.string   "zip"
    t.boolean  "include_radius"
    t.integer  "radius"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "military_occupations", force: :cascade do |t|
    t.string   "service"
    t.string   "category"
    t.string   "code",        index: {name: "index_military_occupations_on_code"}
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
    t.boolean  "active"
  end

  create_table "references", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "job_title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "veteran_id", index: {name: "index_references_on_veteran_id"}
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false, index: {name: "index_sessions_on_session_id", unique: true}
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at", index: {name: "index_sessions_on_updated_at"}
  end

  create_table "site_feedbacks", force: :cascade do |t|
    t.text     "description"
    t.text     "how_to_replicate"
    t.string   "url"
    t.string   "name"
    t.string   "email"
    t.text     "reviewer_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skills", force: :cascade do |t|
    t.text     "name"
    t.text     "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "belongs_to"
    t.boolean  "is_common",  default: false
    t.index name: "index_skills_on_name", unique: true, expression: "\"left\"(name, 1000)"
  end

  create_table "skills_for_military_occupations", force: :cascade do |t|
    t.integer  "skills_translator_model_id", null: false, index: {name: "index_skills_for_moc_on_translator_model_id"}
    t.integer  "military_occupation_id",     null: false, index: {name: "index_skills_for_moc_on_military_occupation_id"}
    t.integer  "skill_id",                   null: false, index: {name: "index_skills_for_moc_on_skill_id"}
    t.float    "relevance",                  null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.decimal  "impressions",                default: 15.0
  end
  add_index "skills_for_military_occupations", ["skills_translator_model_id", "military_occupation_id", "skill_id"], name: "index_for_uniqueness_on_all_fk_ids", unique: true

  create_table "skills_translator_events", force: :cascade do |t|
    t.string   "query_uuid",        null: false, index: {name: "index_skills_translator_events_on_query_uuid"}
    t.datetime "browser_timestamp"
    t.integer  "event_number",      null: false
    t.string   "event_type",        null: false
    t.text     "payload"
    t.integer  "skill_id"
    t.integer  "page"
    t.text     "shown_skills",      default: "[]"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end
  add_index "skills_translator_events", ["query_uuid", "event_number"], name: "index_skills_translator_events_on_query_uuid_and_event_number", unique: true

  create_table "skills_translator_models", force: :cascade do |t|
    t.text     "description"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "last_processed_event_timestamp"
  end

  create_table "skills_translator_sessions", force: :cascade do |t|
    t.string   "query_uuid",                 null: false, index: {name: "index_skills_translator_sessions_on_query_uuid", unique: true}
    t.datetime "query_timestamp",            null: false
    t.text     "query_params",               null: false
    t.integer  "skills_translator_model_id", null: false, index: {name: "index_skills_translator_sessions_on_skills_translator_model_id"}
    t.text     "session_data"
    t.datetime "session_data_timestamp"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false, index: {name: "index_users_on_identity", with: ["provider", "uid"], unique: true}
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token",   index: {name: "index_users_on_reset_password_token", unique: true}
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uid"
    t.string   "provider"
    t.boolean  "va_admin",               default: false
  end

  create_table "veteran_skills", id: false, force: :cascade do |t|
    t.integer "veteran_id", index: {name: "index_veteran_skills_on_veteran_id_and_skill_id", with: ["skill_id"], unique: true}
    t.integer "skill_id"
  end

  create_table "veterans", force: :cascade do |t|
    t.text     "desiredLocation",              default: "--- []\n"
    t.text     "desiredPosition",              default: "--- []\n"
    t.text     "deprecated_skills",            default: "--- []\n"
    t.text     "objective"
    t.datetime "created_at"
    t.datetime "updated_at",                   index: {name: "index_veterans_on_updated_at"}
    t.string   "name"
    t.string   "email"
    t.integer  "user_id",                      index: {name: "index_veterans_on_user_id"}
    t.boolean  "visible",                      default: false, index: {name: "index_veterans_on_visible"}
    t.string   "session_id"
    t.date     "availability_date",            index: {name: "index_veterans_on_availability_date"}
    t.text     "status_categories",            default: "--- []\n"
    t.tsvector "searchable_summary"
    t.datetime "applied_for_alp_date"
    t.string   "accelerated_learning_program"
  end

end
