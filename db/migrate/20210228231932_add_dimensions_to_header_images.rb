class AddDimensionsToHeaderImages < ActiveRecord::Migration[5.2]
  def change
    add_column :header_images, :width, :integer
    add_column :header_images, :height, :integer
  end
end
