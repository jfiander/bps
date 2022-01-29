class MoveApiKeyToApiTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :api_tokens, :key, :string
    add_index :api_tokens, [:key], unique: true

    remove_column :users, :api_key, :string
  end
end
