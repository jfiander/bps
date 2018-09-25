class AddOverrideCostToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :override_cost, :integer
  end
end
