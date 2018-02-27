class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.text :address
      t.text :map_link
      t.text :details
      t.attachment :picture
      t.datetime :deleted_at

      t.timestamps
    end

    add_column :events, :location_id, :integer
  end
end
