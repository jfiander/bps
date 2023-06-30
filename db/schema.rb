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

ActiveRecord::Schema.define(version: 2023_06_30_175933) do

  create_table "albums", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "cover_id"
    t.index ["deleted_at"], name: "index_albums_on_deleted_at"
    t.index ["name"], name: "index_albums_on_name", unique: true
  end

  create_table "announcement_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "hidden_at"
    t.index ["deleted_at"], name: "index_announcement_files_on_deleted_at"
  end

  create_table "api_tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "token"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.string "description"
    t.index ["key"], name: "index_api_tokens_on_key", unique: true
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "award_recipients", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "award_name"
    t.date "year"
    t.integer "user_id"
    t.integer "additional_user_id"
    t.string "name"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_award_recipients_on_deleted_at"
  end

  create_table "bilge_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "year"
    t.integer "month"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_bilge_files_on_deleted_at"
  end

  create_table "bridge_offices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "office"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["office", "deleted_at"], name: "index_bridge_offices_on_office"
    t.index ["user_id", "deleted_at"], name: "index_bridge_offices_on_user_id"
  end

  create_table "committees", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "department"
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["department", "deleted_at"], name: "index_committees_on_department"
    t.index ["name"], name: "index_committees_on_name"
    t.index ["user_id", "deleted_at"], name: "index_committees_on_user_id"
  end

  create_table "course_completions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "course_key"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["user_id", "deleted_at"], name: "index_course_completions_on_user_id"
  end

  create_table "course_includes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "course_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["course_id", "deleted_at"], name: "index_course_includes_on_course_id"
  end

  create_table "course_topics", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "course_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["course_id", "deleted_at"], name: "index_course_topics_on_course_id"
  end

  create_table "dmarc_reports", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "xml"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.binary "proto"
  end

  create_table "event_instructors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["event_id", "deleted_at"], name: "index_event_instructors_on_event_id"
  end

  create_table "event_options", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "event_selection_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.timestamp "deleted_at"
    t.integer "position"
  end

  create_table "event_promo_codes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "event_id"
    t.integer "promo_code_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "deleted_at"], name: "index_event_promo_codes_on_event_id"
    t.index ["promo_code_id", "deleted_at"], name: "index_event_promo_codes_on_code_id"
  end

  create_table "event_selections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "event_id"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.timestamp "deleted_at"
  end

  create_table "event_type_committees", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "event_type_id"
    t.string "committee"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_types", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "event_category"
    t.string "title"
    t.string "image_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "course_key"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_event_types_on_deleted_at"
    t.index ["event_category", "deleted_at"], name: "index_event_types_on_category"
  end

  create_table "events", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "event_type_id"
    t.integer "cost"
    t.text "description"
    t.string "requirements"
    t.string "map_link"
    t.datetime "start_at"
    t.integer "sessions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
    t.integer "prereq_id"
    t.string "flyer_file_name"
    t.string "flyer_content_type"
    t.integer "flyer_file_size"
    t.datetime "flyer_updated_at"
    t.integer "member_cost"
    t.boolean "allow_member_registrations", default: true
    t.boolean "allow_public_registrations", default: true
    t.datetime "deleted_at"
    t.datetime "cutoff_at"
    t.integer "location_id"
    t.boolean "show_in_catalog"
    t.string "google_calendar_event_id"
    t.datetime "reminded_at"
    t.string "google_calendar_link"
    t.boolean "all_day", default: false
    t.string "summary"
    t.string "repeat_pattern", default: "WEEKLY"
    t.integer "registration_limit"
    t.integer "usps_cost"
    t.boolean "advance_payment"
    t.datetime "archived_at"
    t.string "slug"
    t.integer "length_h"
    t.integer "length_m"
    t.boolean "activity_feed"
    t.boolean "online", default: false
    t.string "topic_arn"
    t.string "conference_id_cache"
    t.text "link_override"
    t.string "conference_signature"
    t.boolean "visible", default: true, null: false
    t.text "important_notes"
    t.boolean "quiet", default: false, null: false
    t.index ["event_type_id", "deleted_at"], name: "index_events_on_event_type_id"
    t.index ["slug", "deleted_at"], name: "index_events_on_slug"
    t.index ["start_at", "expires_at", "archived_at", "deleted_at"], name: "index_events_on_dates"
  end

  create_table "float_plan_onboards", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "float_plan_id"
    t.string "name"
    t.integer "age"
    t.string "address"
    t.string "phone"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["float_plan_id", "deleted_at"], name: "index_float_plan_onboards_on_float_plan_id"
  end

  create_table "float_plans", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "boat_type"
    t.string "subtype"
    t.string "hull_color"
    t.string "trim_color"
    t.string "registration_number"
    t.integer "length"
    t.string "boat_name"
    t.string "make"
    t.string "model"
    t.string "year"
    t.string "engine_type_1"
    t.string "engine_type_2"
    t.integer "horse_power"
    t.integer "number_of_engines"
    t.integer "fuel_capacity"
    t.boolean "pfds"
    t.boolean "flares"
    t.boolean "mirror"
    t.boolean "horn"
    t.boolean "smoke"
    t.boolean "flashlight"
    t.boolean "raft"
    t.boolean "epirb"
    t.boolean "paddles"
    t.boolean "food"
    t.boolean "water"
    t.boolean "anchor"
    t.boolean "epirb_16"
    t.boolean "epirb_1215"
    t.boolean "epirb_406"
    t.string "radio"
    t.boolean "radio_vhf"
    t.boolean "radio_ssb"
    t.boolean "radio_cb"
    t.boolean "radio_cell_phone"
    t.string "channels_monitored"
    t.string "call_sign"
    t.string "leave_from"
    t.string "going_to"
    t.datetime "leave_at"
    t.datetime "return_at"
    t.datetime "alert_at"
    t.text "comments"
    t.string "car_make"
    t.string "car_model"
    t.string "car_year"
    t.string "car_color"
    t.string "car_license_plate"
    t.string "trailer_license_plate"
    t.string "car_parked_at"
    t.string "alert_name"
    t.string "alert_phone"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pdf_file_name"
    t.string "pdf_content_type"
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.integer "user_id"
    t.string "hin"
    t.string "deck_color"
    t.string "sail_color"
    t.index ["user_id", "deleted_at"], name: "index_float_plans_on_user_id"
  end

  create_table "generic_payments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "description"
    t.integer "amount"
    t.integer "user_id"
    t.string "email"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_generic_payments_on_deleted_at"
  end

  create_table "glyc_members", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "header_images", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "width"
    t.integer "height"
    t.index ["deleted_at"], name: "index_header_images_on_deleted_at"
  end

  create_table "import_logs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "json"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.binary "proto"
    t.index ["deleted_at"], name: "index_import_logs_on_deleted_at"
  end

  create_table "jobcodes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "code"
    t.integer "year"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.boolean "current", default: true, null: false
    t.boolean "acting", default: false, null: false
    t.index ["user_id", "code", "year"], name: "user_job_year", unique: true
  end

  create_table "locations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "address"
    t.text "map_link"
    t.text "details"
    t.string "picture_file_name"
    t.string "picture_content_type"
    t.integer "picture_file_size"
    t.datetime "picture_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "price_comment"
    t.boolean "favorite"
    t.boolean "virtual"
    t.index ["address"], name: "index_locations_on_address", unique: true, length: 64
    t.index ["deleted_at"], name: "index_locations_on_deleted_at"
  end

  create_table "markdown_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_markdown_files_on_deleted_at"
  end

  create_table "member_applicants", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "member_application_id"
    t.boolean "primary"
    t.string "member_type"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.date "dob"
    t.string "gender"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone_h"
    t.string "phone_c"
    t.string "phone_w"
    t.string "fax"
    t.string "email"
    t.boolean "sea_scout"
    t.string "sig_other_name"
    t.string "boat_type"
    t.string "boat_length"
    t.string "boat_name"
    t.string "previous_certificate"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_member_applicants_on_email", unique: true
    t.index ["member_application_id", "deleted_at"], name: "index_index_applicants_on_application_id"
  end

  create_table "member_applications", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "approved_at"
    t.integer "approver_id"
    t.index ["approved_at", "deleted_at"], name: "index_member_applications_on_approved_at"
  end

  create_table "minutes_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "year"
    t.integer "month"
    t.boolean "excom"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["excom", "deleted_at"], name: "index_minutes_files_on_excom"
  end

  create_table "otw_training_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "otw_training_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["otw_training_id", "deleted_at"], name: "index_otw_tu_on_training_id"
    t.index ["user_id", "deleted_at"], name: "index_otw_tu_on_user_id"
  end

  create_table "otw_trainings", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "course_key"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "boc_level"
    t.index ["deleted_at"], name: "index_otw_trainings_on_deleted_at"
    t.index ["name"], name: "index_otw_trainings_on_name", unique: true
  end

  create_table "past_commanders", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "year"
    t.integer "user_id"
    t.string "name"
    t.boolean "deceased", default: false
    t.string "comment"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_past_commanders_on_deleted_at"
  end

  create_table "payments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "parent_type"
    t.integer "parent_id"
    t.string "transaction_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "paid", default: false
    t.datetime "deleted_at"
    t.string "receipt_file_name"
    t.string "receipt_content_type"
    t.integer "receipt_file_size"
    t.datetime "receipt_updated_at"
    t.string "cost_type"
    t.boolean "refunded"
    t.integer "promo_code_id"
    t.index ["parent_type", "parent_id", "deleted_at"], name: "index_payments_on_parent"
    t.index ["token", "deleted_at"], name: "index_payments_on_token"
    t.index ["transaction_id", "deleted_at"], name: "index_payments_on_transaction_id"
  end

  create_table "photos", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "photo_file_file_name"
    t.string "photo_file_content_type"
    t.integer "photo_file_file_size"
    t.datetime "photo_file_updated_at"
    t.datetime "deleted_at"
    t.index ["album_id", "deleted_at"], name: "index_photos_on_album_id"
  end

  create_table "promo_codes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "code"
    t.datetime "valid_at"
    t.datetime "expires_at"
    t.integer "discount_amount"
    t.string "discount_type"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code", "deleted_at"], name: "index_promo_codes_on_code"
  end

  create_table "registration_options", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "registration_id"
    t.integer "event_option_id"
    t.string "selection"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.timestamp "deleted_at"
  end

  create_table "registration_promo_codes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "registration_id"
    t.integer "promo_code_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["promo_code_id", "deleted_at"], name: "index_registration_promo_codes_on_code_id"
    t.index ["registration_id", "deleted_at"], name: "index_registration_promo_codes_on_registration_id"
  end

  create_table "registrations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "name"
    t.string "phone"
    t.integer "override_cost"
    t.string "override_comment"
    t.integer "user_id"
    t.string "email"
    t.string "subscription_arn"
    t.index ["email", "deleted_at"], name: "index_registrations_on_email"
    t.index ["event_id", "deleted_at"], name: "index_registrations_on_event_id"
    t.index ["user_id", "deleted_at"], name: "index_registrations_on_user_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.datetime "deleted_at"
    t.string "icon"
    t.index ["name", "deleted_at"], name: "index_roles_on_name"
    t.index ["parent_id", "deleted_at"], name: "index_roles_on_parent_id"
  end

  create_table "roster_archive_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "generated_at"
    t.index ["deleted_at"], name: "index_roster_archive_files_on_deleted_at"
  end

  create_table "standing_committee_offices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "committee_name"
    t.integer "user_id"
    t.datetime "term_start_at"
    t.integer "term_length"
    t.datetime "term_expires_at"
    t.boolean "chair", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["committee_name", "deleted_at"], name: "index_standing_committee_offices_on_committee_name"
    t.index ["user_id", "deleted_at"], name: "index_standing_committee_offices_on_user_id"
  end

  create_table "static_pages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "markdown"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["name", "deleted_at"], name: "index_static_pages_on_name"
  end

  create_table "user_roles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["role_id", "deleted_at"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "deleted_at"], name: "index_user_roles_on_user_id"
    t.index ["user_id", "role_id", "deleted_at"], name: "index_user_roles_on_user_id_and_role_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "certificate"
    t.string "first_name"
    t.string "last_name"
    t.string "grade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "rank"
    t.string "profile_photo_file_name"
    t.string "profile_photo_content_type"
    t.integer "profile_photo_file_size"
    t.datetime "profile_photo_updated_at"
    t.string "simple_name", default: ""
    t.integer "mm"
    t.datetime "ed_pro"
    t.datetime "id_expr"
    t.datetime "deleted_at"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.integer "parent_id"
    t.datetime "dues_last_paid_at"
    t.string "customer_id"
    t.datetime "ed_ach"
    t.datetime "senior"
    t.datetime "life"
    t.integer "total_years"
    t.string "phone_h"
    t.string "phone_c"
    t.string "phone_w"
    t.datetime "membership_date"
    t.datetime "last_mm"
    t.boolean "new_layout"
    t.string "rank_override"
    t.string "calendar_rule_id"
    t.date "last_mm_year"
    t.integer "mm_cache"
    t.string "spouse_name"
    t.string "fax"
    t.string "home_port"
    t.date "birthday"
    t.string "boat_name"
    t.string "boat_type"
    t.string "mmsi"
    t.string "call_sign"
    t.datetime "cpr_aed_expires_at"
    t.boolean "permalinks", default: false
    t.text "jumpstart"
    t.boolean "subscribe_on_register", default: false, null: false
    t.string "pushover_token"
    t.boolean "in_latest_import"
    t.boolean "mfa_enabled", default: false, null: false
    t.boolean "dan_boater", default: false, null: false
    t.index ["certificate", "locked_at", "deleted_at"], name: "index_users_on_certificate"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["jumpstart", "locked_at", "deleted_at"], name: "index_users_on_jumpstart", length: { jumpstart: 1 }
    t.index ["locked_at", "deleted_at"], name: "index_users_on_locked_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["simple_name", "locked_at", "deleted_at"], name: "index_users_on_simple_name"
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
