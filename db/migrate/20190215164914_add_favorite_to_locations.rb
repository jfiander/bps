class AddFavoriteToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :favorite, :boolean
  end
end
