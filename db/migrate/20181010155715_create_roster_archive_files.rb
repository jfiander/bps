class CreateRosterArchiveFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :roster_archive_files do |t|
      t.attachment :file
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
