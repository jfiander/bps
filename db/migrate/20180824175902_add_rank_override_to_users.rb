class AddRankOverrideToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :rank_override, :string
  end
end
