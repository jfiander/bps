class ChangePaidOnRegistrations < ActiveRecord::Migration[5.0]
  def change
    change_column :registrations, :paid, :string
  end
end
