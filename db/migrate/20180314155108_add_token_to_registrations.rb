class AddTokenToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :token, :string
  end
end
