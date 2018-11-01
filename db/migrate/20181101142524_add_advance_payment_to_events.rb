class AddAdvancePaymentToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :advance_payment, :boolean
  end
end
