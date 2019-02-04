class AddCPRAEDExpiresAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :cpr_aed_expires_at, :datetime
  end
end
