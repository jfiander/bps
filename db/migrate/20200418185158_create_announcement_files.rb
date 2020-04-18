class CreateAnnouncementFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :announcement_files do |t|
      t.string :title
      t.attachment :file
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
