class AddCoverIdToAlbums < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :cover_id, :integer
  end
end
