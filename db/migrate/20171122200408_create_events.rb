class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.integer :course_type_id
      t.integer :cost
      t.text :description
      t.string :requirements
      t.string :location
      t.string :map_link
      t.datetime :start_at
      t.integer :length
      t.integer :sessions
      t.string :flyer_link

      t.timestamps
    end
  end
end
