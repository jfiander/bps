class AddPriceCommentToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :price_comment, :text
  end
end
