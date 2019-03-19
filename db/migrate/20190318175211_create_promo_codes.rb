class CreatePromoCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :promo_codes do |t|
      t.string :code
      t.datetime :valid_at
      t.datetime :expires_at
      t.integer :discount_amount
      t.string :discount_type
      t.datetime :deleted_at

      t.timestamps
    end

    create_table :registration_promo_codes do |t|
      t.integer :registration_id
      t.integer :promo_code_id
      t.datetime :deleted_at

      t.timestamps
    end

    create_table :event_promo_codes do |t|
      t.integer :event_id
      t.integer :promo_code_id
      t.datetime :deleted_at

      t.timestamps
    end

    add_column :payments, :promo_code_id, :integer
  end
end
