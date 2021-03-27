class ImproveIndexes < ActiveRecord::Migration[5.2]
  def change
    # Add deleted_at to all primary indexes or create a new one if none exist
    add_index :albums, :deleted_at
    add_index :announcement_files, :deleted_at
    add_index :award_recipients, :deleted_at
    add_index :bilge_files, :deleted_at

    remove_index :bridge_offices, :office
    remove_index :bridge_offices, :user_id
    add_index :bridge_offices, %i[office deleted_at], name: :index_bridge_offices_on_office
    add_index :bridge_offices, %i[user_id deleted_at], name: :index_bridge_offices_on_user_id

    remove_index :committees, :department
    remove_index :committees, :user_id
    add_index :committees, %i[department deleted_at], name: :index_committees_on_department
    add_index :committees, %i[user_id deleted_at], name: :index_committees_on_user_id

    remove_index :course_completions, :user_id
    add_index :course_completions, %i[user_id deleted_at], name: :index_course_completions_on_user_id

    remove_index :course_includes, :course_id
    add_index :course_includes, %i[course_id deleted_at], name: :index_course_includes_on_course_id

    remove_index :course_topics, :course_id
    add_index :course_topics, %i[course_id deleted_at], name: :index_course_topics_on_course_id

    remove_index :event_instructors, :event_id
    remove_index :event_instructors, :user_id
    add_index :event_instructors, %i[event_id deleted_at], name: :index_event_instructors_on_event_id

    remove_index :event_promo_codes, :event_id
    remove_index :event_promo_codes, :promo_code_id
    add_index :event_promo_codes, %i[event_id deleted_at], name: :index_event_promo_codes_on_event_id
    add_index :event_promo_codes, %i[promo_code_id deleted_at], name: :index_event_promo_codes_on_code_id

    add_index :event_types, :deleted_at
    add_index :event_types, %i[event_category deleted_at], name: :index_event_types_on_category

    remove_index :events, :event_type_id
    add_index :events, %i[event_type_id deleted_at], name: :index_events_on_event_type_id
    add_index :events, %i[start_at expires_at archived_at deleted_at], name: :index_events_on_dates
    add_index :events, %i[slug deleted_at], name: :index_events_on_slug

    add_index :float_plan_onboards, %i[float_plan_id deleted_at], name: :index_float_plan_onboards_on_float_plan_id

    add_index :float_plans, %i[user_id deleted_at], name: :index_float_plans_on_user_id

    add_index :generic_payments, :deleted_at
    add_index :header_images, :deleted_at
    add_index :import_logs, :deleted_at
    add_index :locations, :deleted_at
    add_index :markdown_files, :deleted_at

    add_index :member_applicants, %i[member_application_id deleted_at], name: :index_index_applicants_on_application_id

    add_index :member_applications, %i[approved_at deleted_at], name: :index_member_applications_on_approved_at

    add_index :minutes_files, %i[excom deleted_at], name: :index_minutes_files_on_excom

    add_index :otw_training_users, %i[otw_training_id deleted_at], name: :index_otw_tu_on_training_id
    add_index :otw_training_users, %i[user_id deleted_at], name: :index_otw_tu_on_user_id

    add_index :otw_trainings, :deleted_at
    add_index :past_commanders, :deleted_at

    remove_index :payments, %i[parent_type parent_id]
    remove_index :payments, :token
    remove_index :payments, :transaction_id
    add_index :payments, %i[parent_type parent_id deleted_at], name: :index_payments_on_parent
    add_index :payments, %i[token deleted_at], name: :index_payments_on_token
    add_index :payments, %i[transaction_id deleted_at], name: :index_payments_on_transaction_id

    remove_index :photos, :album_id
    add_index :photos, %i[album_id deleted_at], name: :index_photos_on_album_id

    remove_index :promo_codes, :code
    add_index :promo_codes, %i[code deleted_at], name: :index_promo_codes_on_code

    add_index :registration_promo_codes, %i[registration_id deleted_at], name: :index_registration_promo_codes_on_registration_id
    add_index :registration_promo_codes, %i[promo_code_id deleted_at], name: :index_registration_promo_codes_on_code_id

    remove_index :registrations, :event_id
    add_index :registrations, %i[event_id deleted_at], name: :index_registrations_on_event_id
    add_index :registrations, %i[user_id deleted_at], name: :index_registrations_on_user_id
    add_index :registrations, %i[email deleted_at], name: :index_registrations_on_email

    remove_index :roles, :name
    remove_index :roles, :parent_id
    add_index :roles, %i[name deleted_at], name: :index_roles_on_name
    add_index :roles, %i[parent_id deleted_at], name: :index_roles_on_parent_id

    add_index :roster_archive_files, :deleted_at

    remove_index :standing_committee_offices, :committee_name
    remove_index :standing_committee_offices, :user_id
    add_index :standing_committee_offices, %i[committee_name deleted_at], name: :index_standing_committee_offices_on_committee_name
    add_index :standing_committee_offices, %i[user_id deleted_at], name: :index_standing_committee_offices_on_user_id

    remove_index :static_pages, :name
    add_index :static_pages, %i[name deleted_at], name: :index_static_pages_on_name

    remove_index :user_roles, :role_id
    remove_index :user_roles, :user_id
    remove_index :user_roles, %i[user_id role_id]
    add_index :user_roles, %i[user_id deleted_at], name: :index_user_roles_on_user_id
    add_index :user_roles, %i[role_id deleted_at], name: :index_user_roles_on_role_id
    add_index :user_roles, %i[user_id role_id deleted_at], name: :index_user_roles_on_user_id_and_role_id

    remove_index :users, :certificate
    remove_index :users, :jumpstart
    add_index :users, %i[certificate locked_at deleted_at], name: :index_users_on_certificate
    add_index :users, %i[jumpstart locked_at deleted_at], name: :index_users_on_jumpstart, length: { jumpstart: 1 }
    add_index :users, %i[locked_at deleted_at], name: :index_users_on_locked_at
    add_index :users, %i[simple_name locked_at deleted_at], name: :index_users_on_simple_name
  end
end
