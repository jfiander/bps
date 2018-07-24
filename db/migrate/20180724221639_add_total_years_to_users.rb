class AddTotalYearsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :total_years, :integer
  end
end
