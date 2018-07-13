class AddRemindedAtToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :reminded_at, :datetime
  end
end
