class AddMmTrackingToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_mm_year, :date
    add_column :users, :mm_cache, :integer
  end
end
