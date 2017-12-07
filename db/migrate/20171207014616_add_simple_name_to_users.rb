class AddSimpleNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :simple_name, :string
  end
end
