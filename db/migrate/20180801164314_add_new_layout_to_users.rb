class AddNewLayoutToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :new_layout, :boolean
  end
end
