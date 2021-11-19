class AddPushoverTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pushover_token, :string
  end
end
