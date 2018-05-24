class RemoveItemRequests < ActiveRecord::Migration[5.0]
  def up
    drop_table :item_requests
  end

  def down
    create_table :item_requests do |t|
      t.integer :user_id
      t.integer :store_item_id
      t.boolean :fulfilled, default: false

      t.timestamps
    end
  end
end
