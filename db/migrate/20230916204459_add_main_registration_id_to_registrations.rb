class AddMainRegistrationIdToRegistrations < ActiveRecord::Migration[6.1]
  def change
    add_column :registrations, :main_registration_id, :integer
  end
end
