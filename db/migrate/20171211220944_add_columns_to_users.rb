class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :mm, :integer
    add_column :users, :ed_pro, :datetime
    add_column :users, :id_expr, :datetime
  end
end
