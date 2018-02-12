class AddNameAndPhoneToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :name, :string
    add_column :registrations, :phone, :string
  end
end
