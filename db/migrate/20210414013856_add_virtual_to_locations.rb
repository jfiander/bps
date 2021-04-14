class AddVirtualToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :virtual, :boolean
  end
end
