class CreateRefunds < ActiveRecord::Migration[5.2]
  def change
    create_table :refunds do |t|
      t.integer :payment_id
      t.string :amount
      t.datetime :deleted_at
      t.string :transaction_id
    end

    add_index :refunds, :payment_id
  end
end
