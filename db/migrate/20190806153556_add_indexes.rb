class AddIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :bridge_offices, :office
    add_index :bridge_offices, :user_id

    add_index :committees, :department
    add_index :committees, :name
    add_index :committees, :user_id

    add_index :course_completions, :user_id

    add_index :course_includes, :course_id

    add_index :course_topics, :course_id

    add_index :events, :event_type_id

    add_index :event_instructors, :user_id
    add_index :event_instructors, :event_id

    add_index :event_promo_codes, :event_id
    add_index :event_promo_codes, :promo_code_id

    add_index :payments, :transaction_id
    add_index :payments, :token
    add_index :payments, %i[parent_type parent_id]

    add_index :photos, :album_id

    add_index :promo_codes, :code

    add_index :registrations, :event_id

    add_index :roles, :name
    add_index :roles, :parent_id

    add_index :standing_committee_offices, :committee_name
    add_index :standing_committee_offices, :user_id

    add_index :static_pages, :name

    change_column :users, :certificate, :string, unique: true
    add_index :users, :certificate

    add_index :user_roles, :user_id
    add_index :user_roles, :role_id
    add_index :user_roles, %i[user_id role_id]
  end
end
