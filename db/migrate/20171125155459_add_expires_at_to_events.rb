class AddExpiresAtToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :expires_at, :datetime
  end
end
