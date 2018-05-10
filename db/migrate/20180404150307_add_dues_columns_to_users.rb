class AddDuesColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :parent_id, :integer
    add_column :users, :dues_last_paid_at, :datetime
  end
end
