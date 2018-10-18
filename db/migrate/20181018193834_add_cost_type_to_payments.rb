class AddCostTypeToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :cost_type, :string
  end
end
