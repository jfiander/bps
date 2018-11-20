class AddRefundedToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :refunded, :boolean
  end
end
