class AddAttachmentPhotoFileToPhotos < ActiveRecord::Migration[5.0]
  def self.up
    change_table :photos do |t|
      t.attachment :photo_file
    end
  end

  def self.down
    remove_attachment :photos, :photo_file
  end
end
