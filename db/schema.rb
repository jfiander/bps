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

ActiveRecord::Schema.define(version: 2019_02_15_164914) do

  create_table "albums", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "award_recipients", force: :cascade do |t|
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
  end

  create_table "bilge_files", force: :cascade do |t|
    t.integer "year"
    t.integer "month"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bridge_offices", force: :cascade do |t|
    t.string "office"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "committees", force: :cascade do |t|
    t.string "department"
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "course_completions", force: :cascade do |t|
    t.integer "user_id"
    t.string "course_key"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "course_includes", force: :cascade do |t|
    t.integer "course_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "course_topics", force: :cascade do |t|
    t.integer "course_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "event_instructors", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "event_types", force: :cascade do |t|
    t.string "event_category"
    t.string "title"
    t.string "image_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "course_key"
    t.datetime "deleted_at"
  end

  create_table "events", force: :cascade do |t|
    t.integer "event_type_id"
    t.integer "cost"
    t.text "description"
    t.string "requirements"
    t.string "map_link"
    t.datetime "start_at"
    t.time "length"
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
  end

  create_table "float_plan_onboards", force: :cascade do |t|
    t.integer "float_plan_id"
    t.string "name"
    t.integer "age"
    t.string "address"
    t.string "phone"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "float_plans", force: :cascade do |t|
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
  end

  create_table "header_images", force: :cascade do |t|
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "import_logs", force: :cascade do |t|
    t.text "json"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
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
  end

  create_table "markdown_files", force: :cascade do |t|
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "member_applicants", force: :cascade do |t|
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
  end

  create_table "member_applications", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "approved_at"
    t.integer "approver_id"
  end

  create_table "minutes_files", force: :cascade do |t|
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
  end

  create_table "otw_training_users", force: :cascade do |t|
    t.integer "otw_training_id"
    t.integer "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "otw_trainings", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "course_key"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "boc_level"
  end

  create_table "past_commanders", force: :cascade do |t|
    t.date "year"
    t.integer "user_id"
    t.string "name"
    t.boolean "deceased", default: false
    t.string "comment"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
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
  end

  create_table "photos", force: :cascade do |t|
    t.integer "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "photo_file_file_name"
    t.string "photo_file_content_type"
    t.integer "photo_file_file_size"
    t.datetime "photo_file_updated_at"
    t.datetime "deleted_at"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "name"
    t.string "phone"
    t.integer "override_cost"
    t.string "override_comment"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.datetime "deleted_at"
  end

  create_table "roster_archive_files", force: :cascade do |t|
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "generated_at"
  end

  create_table "standing_committee_offices", force: :cascade do |t|
    t.string "committee_name"
    t.integer "user_id"
    t.datetime "term_start_at"
    t.integer "term_length"
    t.datetime "term_expires_at"
    t.boolean "chair"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "static_pages", force: :cascade do |t|
    t.string "name"
    t.string "markdown"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "users", force: :cascade do |t|
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 1073741823
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
