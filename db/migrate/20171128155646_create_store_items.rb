class CreateStoreItems < ActiveRecord::Migration[5.0]
  def change
    create_table :store_items do |t|
      t.string :name
      t.string :description
      t.decimal :price, precision: 5, scale: 2
      t.integer :stock
      t.text :options
      t.attachment :image

      t.timestamps
    end
  end
end
