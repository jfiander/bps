class CreateGenericPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :generic_payments do |t|
      t.string :description
      t.integer :amount
      t.integer :user_id
      t.string :email
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
