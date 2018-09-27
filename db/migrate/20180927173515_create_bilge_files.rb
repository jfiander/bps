class CreateBilgeFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :bilge_files do |t|
      t.integer :year
      t.integer :month
      t.attachment :file
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
