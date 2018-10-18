class AddReceiptToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :receipt_file_name, :string
    add_column :payments, :receipt_content_type, :string
    add_column :payments, :receipt_file_size, :integer
    add_column :payments, :receipt_updated_at, :datetime
  end
end
