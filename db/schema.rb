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

ActiveRecord::Schema.define(version: 20180215191053) do

  create_table "albums", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "bridge_offices", force: :cascade do |t|
    t.string   "office"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "committees", force: :cascade do |t|
    t.string   "department"
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "course_completions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "course_key"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "course_includes", force: :cascade do |t|
    t.integer  "course_id"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "course_topics", force: :cascade do |t|
    t.integer  "course_id"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_instructors", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_types", force: :cascade do |t|
    t.string   "event_category"
    t.string   "title"
    t.string   "image_link"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "course_key"
    t.datetime "deleted_at"
  end

  create_table "events", force: :cascade do |t|
    t.integer  "event_type_id"
    t.integer  "cost"
    t.text     "description"
    t.string   "requirements"
    t.string   "location"
    t.string   "map_link"
    t.datetime "start_at"
    t.datetime "length"
    t.integer  "sessions"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.datetime "expires_at"
    t.integer  "prereq_id"
    t.string   "flyer_file_name"
    t.string   "flyer_content_type"
    t.integer  "flyer_file_size"
    t.datetime "flyer_updated_at"
    t.integer  "member_cost"
    t.boolean  "allow_member_registrations", default: true
    t.boolean  "allow_public_registrations", default: true
    t.datetime "deleted_at"
  end

  create_table "item_requests", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "store_item_id"
    t.boolean  "fulfilled",     default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "deleted_at"
  end

  create_table "markdown_files", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "deleted_at"
  end

  create_table "photos", force: :cascade do |t|
    t.integer  "album_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "photo_file_file_name"
    t.string   "photo_file_content_type"
    t.integer  "photo_file_file_size"
    t.datetime "photo_file_updated_at"
    t.datetime "deleted_at"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email"
    t.integer  "event_id"
    t.boolean  "paid"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string   "name"
    t.string   "phone"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "parent_id"
    t.datetime "deleted_at"
  end

  create_table "standing_committee_offices", force: :cascade do |t|
    t.string   "committee_name"
    t.integer  "user_id"
    t.datetime "term_start_at"
    t.integer  "term_length"
    t.datetime "term_expires_at"
    t.boolean  "chair"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "deleted_at"
  end

  create_table "static_pages", force: :cascade do |t|
    t.string   "name"
    t.string   "markdown"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "store_items", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.decimal  "price",              precision: 5, scale: 2
    t.integer  "stock"
    t.text     "options"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.datetime "deleted_at"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "certificate"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "grade"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "email",                      default: "", null: false
    t.string   "encrypted_password",         default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",            default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",          default: 0
    t.string   "rank"
    t.string   "profile_photo_file_name"
    t.string   "profile_photo_content_type"
    t.integer  "profile_photo_file_size"
    t.datetime "profile_photo_updated_at"
    t.string   "simple_name",                default: ""
    t.integer  "mm"
    t.datetime "ed_pro"
    t.datetime "id_expr"
    t.datetime "deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",                     null: false
    t.integer  "item_id",                       null: false
    t.string   "event",                         null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 1073741823
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
