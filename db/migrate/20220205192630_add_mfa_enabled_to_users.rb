class AddMfaEnabledToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mfa_enabled, :boolean, default: false, null: false
  end
end
