class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.string :parent_type
      t.integer :parent_id
      t.string :transaction_id
      t.string :token

      t.timestamps
    end
  end
end
