class AddIndexesOnApiToken < ActiveRecord::Migration[5.2]
  def change
    add_index :api_tokens, :token, unique: true
    add_index :api_tokens, :user_id
  end
end
