class AddAchievementsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ed_ach, :datetime
    add_column :users, :senior, :datetime
    add_column :users, :life, :datetime
  end
end
