class AddRosterColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :spouse_name, :string
    add_column :users, :fax, :string
    add_column :users, :home_port, :string
    add_column :users, :birthday, :date
    add_column :users, :boat_name, :string
    add_column :users, :boat_type, :string
    add_column :users, :mmsi, :string
    add_column :users, :call_sign, :string
  end
end
