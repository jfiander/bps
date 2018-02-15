class AddDeletedAtToAlbumsAndPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :albums, :deleted_at, :datetime
    add_column :photos, :deleted_at, :datetime
  end
end
