class AddJumpstartToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :jumpstart, :text
    add_index :users, :jumpstart
  end
end
