class AddDescriptionToApiTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :api_tokens, :description, :string
  end
end
