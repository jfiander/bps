class CreateElections < ActiveRecord::Migration[5.2]
  def change
    create_table :elections do |t|
      t.string :description
      t.string :style
      t.string :restriction
      t.datetime :open_at
      t.datetime :closed_at

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
