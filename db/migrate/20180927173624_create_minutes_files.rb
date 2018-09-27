class CreateMinutesFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :minutes_files do |t|
      t.integer :year
      t.integer :month
      t.boolean :excom
      t.attachment :file
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
