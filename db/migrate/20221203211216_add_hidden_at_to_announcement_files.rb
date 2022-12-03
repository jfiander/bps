class AddHiddenAtToAnnouncementFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :announcement_files, :hidden_at, :datetime
  end
end
