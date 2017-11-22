class CreateCommittees < ActiveRecord::Migration[5.0]
  def change
    create_table :committees do |t|
      t.string :department
      t.string :name
      t.integer :chair_id

      t.timestamps
    end
  end
end
