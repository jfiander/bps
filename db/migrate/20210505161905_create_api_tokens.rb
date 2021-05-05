class CreateApiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :api_tokens do |t|
      t.string :token
      t.integer :user_id
      t.datetime :deleted_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end
