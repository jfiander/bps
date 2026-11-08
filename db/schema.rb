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

ActiveRecord::Schema[8.1].define(version: 2025_03_14_203534) do
  create_table "albums", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "cover_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_albums_on_deleted_at"
    t.index ["name"], name: "index_albums_on_name", unique: true
  end

  create_table "announcement_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "file_content_type"
    t.string "file_file_name"
    t.integer "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.datetime "hidden_at", precision: nil
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_announcement_files_on_deleted_at"
  end

  create_table "api_tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "description"
    t.datetime "expires_at", precision: nil
    t.string "key"
    t.string "token"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["key"], name: "index_api_tokens_on_key", unique: true
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "award_recipients", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "additional_user_id"
    t.string "award_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "name"
    t.string "photo_content_type"
    t.string "photo_file_name"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.date "year"
    t.index ["deleted_at"], name: "index_award_recipients_on_deleted_at"
  end

  create_table "bilge_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "file_content_type"
    t.string "file_file_name"
    t.integer "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.integer "month"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "year"
    t.index ["deleted_at"], name: "index_bilge_files_on_deleted_at"
  end

  create_table "bridge_offices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "office"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["office", "deleted_at"], name: "index_bridge_offices_on_office"
    t.index ["user_id", "deleted_at"], name: "index_bridge_offices_on_user_id"
  end

  create_table "committees", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "department"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["department", "deleted_at"], name: "index_committees_on_department"
    t.index ["name"], name: "index_committees_on_name"
    t.index ["user_id", "deleted_at"], name: "index_committees_on_user_id"
  end

  create_table "course_completions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "course_key"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "date", precision: nil
    t.datetime "deleted_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["user_id", "deleted_at"], name: "index_course_completions_on_user_id"
  end

  create_table "course_includes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "course_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "text"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["course_id", "deleted_at"], name: "index_course_includes_on_course_id"
  end

  create_table "course_topics", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "course_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "text"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["course_id", "deleted_at"], name: "index_course_topics_on_course_id"
  end

  create_table "dmarc_reports", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.string "filename"
    t.binary "proto"
    t.binary "sources_proto"
    t.datetime "updated_at", null: false
    t.text "xml"
  end

  create_table "event_instructors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "event_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["event_id", "deleted_at"], name: "index_event_instructors_on_event_id"
  end

  create_table "event_options", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.timestamp "deleted_at"
    t.integer "event_selection_id"
    t.string "name"
    t.integer "position"
    t.datetime "updated_at", null: false
  end

  create_table "event_promo_codes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "event_id"
    t.integer "promo_code_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id", "deleted_at"], name: "index_event_promo_codes_on_event_id"
    t.index ["promo_code_id", "deleted_at"], name: "index_event_promo_codes_on_code_id"
  end

  create_table "event_selections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.timestamp "deleted_at"
    t.string "description"
    t.integer "event_id"
    t.datetime "updated_at", null: false
  end

  create_table "event_type_committees", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "committee"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "event_type_id"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "event_types", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "course_key"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "event_category"
    t.string "image_link"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_event_types_on_deleted_at"
    t.index ["event_category", "deleted_at"], name: "index_event_types_on_category"
  end

  create_table "events", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "activity_feed"
    t.integer "additional_registration_cost"
    t.boolean "advance_payment"
    t.boolean "all_day", default: false
    t.boolean "allow_member_registrations", default: true
    t.boolean "allow_public_registrations", default: true
    t.boolean "allow_quick_registration", default: true, null: false
    t.datetime "archived_at", precision: nil
    t.string "conference_id_cache"
    t.string "conference_signature"
    t.integer "cost"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "cutoff_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.text "description"
    t.integer "event_type_id"
    t.datetime "expires_at", precision: nil
    t.string "flyer_content_type"
    t.string "flyer_file_name"
    t.integer "flyer_file_size"
    t.datetime "flyer_updated_at", precision: nil
    t.string "google_calendar_event_id"
    t.string "google_calendar_link"
    t.text "important_notes"
    t.integer "length_h"
    t.integer "length_m"
    t.text "link_override"
    t.integer "location_id"
    t.string "map_link"
    t.integer "member_cost"
    t.boolean "online", default: false
    t.integer "prereq_id"
    t.boolean "quiet", default: false, null: false
    t.integer "registration_limit"
    t.datetime "reminded_at", precision: nil
    t.string "repeat_pattern", default: "WEEKLY"
    t.string "requirements"
    t.integer "sessions"
    t.boolean "show_in_catalog"
    t.string "slug"
    t.datetime "start_at", precision: nil
    t.string "summary"
    t.string "topic_arn"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "usps_cost"
    t.boolean "visible", default: true, null: false
    t.index ["event_type_id", "deleted_at"], name: "index_events_on_event_type_id"
    t.index ["slug", "deleted_at"], name: "index_events_on_slug"
    t.index ["start_at", "expires_at", "archived_at", "deleted_at"], name: "index_events_on_dates"
  end

  create_table "float_plan_onboards", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address"
    t.integer "age"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "float_plan_id"
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["float_plan_id", "deleted_at"], name: "index_float_plan_onboards_on_float_plan_id"
  end

  create_table "float_plans", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "alert_at", precision: nil
    t.string "alert_name"
    t.string "alert_phone"
    t.boolean "anchor"
    t.string "boat_name"
    t.string "boat_type"
    t.string "call_sign"
    t.string "car_color"
    t.string "car_license_plate"
    t.string "car_make"
    t.string "car_model"
    t.string "car_parked_at"
    t.string "car_year"
    t.string "channels_monitored"
    t.text "comments"
    t.datetime "created_at", precision: nil, null: false
    t.string "deck_color"
    t.datetime "deleted_at", precision: nil
    t.string "engine_type_1"
    t.string "engine_type_2"
    t.boolean "epirb"
    t.boolean "epirb_1215"
    t.boolean "epirb_16"
    t.boolean "epirb_406"
    t.boolean "flares"
    t.boolean "flashlight"
    t.boolean "food"
    t.integer "fuel_capacity"
    t.string "going_to"
    t.string "hin"
    t.boolean "horn"
    t.integer "horse_power"
    t.string "hull_color"
    t.datetime "leave_at", precision: nil
    t.string "leave_from"
    t.integer "length"
    t.string "make"
    t.boolean "mirror"
    t.string "model"
    t.string "name"
    t.integer "number_of_engines"
    t.boolean "paddles"
    t.string "pdf_content_type"
    t.string "pdf_file_name"
    t.integer "pdf_file_size"
    t.datetime "pdf_updated_at", precision: nil
    t.boolean "pfds"
    t.string "phone"
    t.string "radio"
    t.boolean "radio_cb"
    t.boolean "radio_cell_phone"
    t.boolean "radio_ssb"
    t.boolean "radio_vhf"
    t.boolean "raft"
    t.string "registration_number"
    t.datetime "return_at", precision: nil
    t.string "sail_color"
    t.boolean "smoke"
    t.string "subtype"
    t.string "trailer_license_plate"
    t.string "trim_color"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.boolean "water"
    t.string "year"
    t.index ["user_id", "deleted_at"], name: "index_float_plans_on_user_id"
  end

  create_table "generic_payments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "amount"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "description"
    t.string "email"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["deleted_at"], name: "index_generic_payments_on_deleted_at"
  end

  create_table "glyc_members", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "email"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "header_images", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "file_content_type"
    t.string "file_file_name"
    t.integer "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.integer "height"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "width"
    t.index ["deleted_at"], name: "index_header_images_on_deleted_at"
  end

  create_table "import_logs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.text "json"
    t.binary "proto"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_import_logs_on_deleted_at"
  end

  create_table "jobcodes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "acting", default: false, null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.boolean "current", default: true, null: false
    t.datetime "deleted_at", precision: nil
    t.string "description"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "year"
    t.index ["user_id", "code", "year"], name: "user_job_year", unique: true
  end

  create_table "locations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.text "details"
    t.boolean "favorite"
    t.text "map_link"
    t.string "picture_content_type"
    t.string "picture_file_name"
    t.integer "picture_file_size"
    t.datetime "picture_updated_at", precision: nil
    t.text "price_comment"
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "virtual"
    t.index ["address"], name: "index_locations_on_address", unique: true, length: 64
    t.index ["deleted_at"], name: "index_locations_on_deleted_at"
  end

  create_table "markdown_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "file_content_type"
    t.string "file_file_name"
    t.integer "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_markdown_files_on_deleted_at"
  end

  create_table "member_applicants", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address_1"
    t.string "address_2"
    t.string "boat_length"
    t.string "boat_name"
    t.string "boat_type"
    t.string "city"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.date "dob"
    t.string "email"
    t.string "fax"
    t.string "first_name"
    t.string "gender"
    t.string "last_name"
    t.integer "member_application_id"
    t.string "member_type"
    t.string "middle_name"
    t.string "phone_c"
    t.string "phone_h"
    t.string "phone_w"
    t.string "previous_certificate"
    t.boolean "primary"
    t.boolean "sea_scout"
    t.string "sig_other_name"
    t.string "state"
    t.datetime "updated_at", precision: nil, null: false
    t.string "zip"
    t.index ["email"], name: "index_member_applicants_on_email", unique: true
    t.index ["member_application_id", "deleted_at"], name: "index_index_applicants_on_application_id"
  end

  create_table "member_applications", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "approved_at", precision: nil
    t.integer "approver_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["approved_at", "deleted_at"], name: "index_member_applications_on_approved_at"
  end

  create_table "minutes_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.boolean "excom"
    t.string "file_content_type"
    t.string "file_file_name"
    t.integer "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.integer "month"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "year"
    t.index ["excom", "deleted_at"], name: "index_minutes_files_on_excom"
  end

  create_table "otw_training_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "otw_training_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["otw_training_id", "deleted_at"], name: "index_otw_tu_on_training_id"
    t.index ["user_id", "deleted_at"], name: "index_otw_tu_on_user_id"
  end

  create_table "otw_trainings", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "boc_level"
    t.string "course_key"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "description"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_otw_trainings_on_deleted_at"
    t.index ["name"], name: "index_otw_trainings_on_name", unique: true
  end

  create_table "past_commanders", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "comment"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "deceased", default: false
    t.datetime "deleted_at", precision: nil
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.date "year"
    t.index ["deleted_at"], name: "index_past_commanders_on_deleted_at"
  end

  create_table "payments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "cost_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.boolean "paid", default: false
    t.integer "parent_id"
    t.string "parent_type"
    t.integer "promo_code_id"
    t.string "receipt_content_type"
    t.string "receipt_file_name"
    t.integer "receipt_file_size"
    t.datetime "receipt_updated_at", precision: nil
    t.boolean "refunded"
    t.string "token"
    t.string "transaction_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["parent_type", "parent_id", "deleted_at"], name: "index_payments_on_parent"
    t.index ["token", "deleted_at"], name: "index_payments_on_token"
    t.index ["transaction_id", "deleted_at"], name: "index_payments_on_transaction_id"
  end

  create_table "photos", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "album_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "photo_file_content_type"
    t.string "photo_file_file_name"
    t.integer "photo_file_file_size"
    t.datetime "photo_file_updated_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["album_id", "deleted_at"], name: "index_photos_on_album_id"
  end

  create_table "promo_codes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "discount_amount"
    t.string "discount_type"
    t.datetime "expires_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "valid_at", precision: nil
    t.index ["code", "deleted_at"], name: "index_promo_codes_on_code"
  end

  create_table "registration_options", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.timestamp "deleted_at"
    t.integer "event_option_id"
    t.integer "registration_id"
    t.string "selection"
    t.datetime "updated_at", null: false
  end

  create_table "registration_promo_codes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "promo_code_id"
    t.integer "registration_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["promo_code_id", "deleted_at"], name: "index_registration_promo_codes_on_code_id"
    t.index ["registration_id", "deleted_at"], name: "index_registration_promo_codes_on_registration_id"
  end

  create_table "registrations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "email"
    t.integer "event_id"
    t.integer "main_registration_id"
    t.string "name"
    t.string "override_comment"
    t.integer "override_cost"
    t.string "phone"
    t.string "subscription_arn"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["email", "deleted_at"], name: "index_registrations_on_email"
    t.index ["event_id", "deleted_at"], name: "index_registrations_on_event_id"
    t.index ["user_id", "deleted_at"], name: "index_registrations_on_user_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "icon"
    t.string "name"
    t.integer "parent_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name", "deleted_at"], name: "index_roles_on_name"
    t.index ["parent_id", "deleted_at"], name: "index_roles_on_parent_id"
  end

  create_table "roster_archive_files", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "file_content_type"
    t.string "file_file_name"
    t.integer "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.datetime "generated_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deleted_at"], name: "index_roster_archive_files_on_deleted_at"
  end

  create_table "standing_committee_offices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "chair", default: false
    t.string "committee_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.boolean "indefinite", default: false, null: false
    t.datetime "term_expires_at", precision: nil
    t.integer "term_length"
    t.datetime "term_start_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["committee_name", "deleted_at"], name: "index_standing_committee_offices_on_committee_name"
    t.index ["user_id", "deleted_at"], name: "index_standing_committee_offices_on_user_id"
  end

  create_table "static_pages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.text "markdown"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name", "deleted_at"], name: "index_static_pages_on_name"
  end

  create_table "user_roles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "role_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["role_id", "deleted_at"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "deleted_at"], name: "index_user_roles_on_user_id"
    t.index ["user_id", "role_id", "deleted_at"], name: "index_user_roles_on_user_id_and_role_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address_1"
    t.string "address_2"
    t.date "birthday"
    t.string "boat_name"
    t.string "boat_type"
    t.string "calendar_rule_id"
    t.string "call_sign"
    t.string "certificate"
    t.string "city"
    t.datetime "cpr_aed_expires_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "customer_id"
    t.boolean "dan_boater", default: false, null: false
    t.datetime "deleted_at", precision: nil
    t.datetime "dues_last_paid_at", precision: nil
    t.datetime "ed_ach", precision: nil
    t.datetime "ed_pro", precision: nil
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "fax"
    t.string "first_name"
    t.string "grade"
    t.string "home_port"
    t.datetime "id_expr", precision: nil
    t.boolean "in_latest_import"
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.text "jumpstart"
    t.datetime "last_mm", precision: nil
    t.date "last_mm_year"
    t.string "last_name"
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.datetime "life", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "membership_date", precision: nil
    t.boolean "mfa_enabled", default: false, null: false
    t.integer "mm"
    t.integer "mm_cache"
    t.string "mmsi"
    t.boolean "new_layout"
    t.integer "parent_id"
    t.boolean "permalinks", default: false
    t.string "phone_c"
    t.string "phone_c_preferred"
    t.string "phone_h"
    t.string "phone_w"
    t.string "preferred_flag_rank"
    t.string "preferred_pin_rank"
    t.string "preferred_stripe_rank"
    t.string "profile_photo_content_type"
    t.string "profile_photo_file_name"
    t.integer "profile_photo_file_size"
    t.datetime "profile_photo_updated_at", precision: nil
    t.string "pushover_token"
    t.string "rank"
    t.string "rank_override"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.datetime "senior", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.string "simple_name", default: ""
    t.string "spouse_name"
    t.string "state"
    t.boolean "subscribe_on_register", default: false, null: false
    t.integer "total_years"
    t.string "unlock_token"
    t.datetime "updated_at", precision: nil, null: false
    t.string "zip"
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
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.text "object", size: :long
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end
end
