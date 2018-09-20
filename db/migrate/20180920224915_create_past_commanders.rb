class CreatePastCommanders < ActiveRecord::Migration[5.2]
  def change
    create_table :past_commanders do |t|
      t.date :year
      t.integer :user_id
      t.string :name
      t.boolean :deceased, default: false
      t.string :comment
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
