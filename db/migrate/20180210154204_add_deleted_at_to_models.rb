class AddDeletedAtToModels < ActiveRecord::Migration[5.0]
  def change
    add_column :committees, :deleted_at, :datetime
    add_column :course_completions, :deleted_at, :datetime
    add_column :event_types, :deleted_at, :datetime
    add_column :events, :deleted_at, :datetime
    add_column :item_requests, :deleted_at, :datetime
    add_column :markdown_files, :deleted_at, :datetime
    add_column :registrations, :deleted_at, :datetime
    add_column :roles, :deleted_at, :datetime
    add_column :standing_committee_offices, :deleted_at, :datetime
    add_column :static_pages, :deleted_at, :datetime
    add_column :store_items, :deleted_at, :datetime
    add_column :user_roles, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime
  end
end
