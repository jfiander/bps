class CreateItemRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :item_requests do |t|
      t.integer :user_id
      t.integer :store_item_id
      t.boolean :fulfilled, default: false

      t.timestamps
    end
  end
end
