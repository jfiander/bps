class CreateEventTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :event_types do |t|
      t.integer :event_category_id
      t.string :title
      t.string :image_link

      t.timestamps
    end
  end
end
