class AddDefaultToSimpleNameOnUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :simple_name, :string, default: ""
  end
end
