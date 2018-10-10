class AddGeneratedAtToRosterArchiveFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :roster_archive_files, :generated_at, :datetime
  end
end
