class AddTransactionIdToRegistrations < ActiveRecord::Migration[5.0]
  def change
    add_column :registrations, :transaction_id, :string
  end
end
