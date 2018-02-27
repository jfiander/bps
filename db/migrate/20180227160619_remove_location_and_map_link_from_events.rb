class RemoveLocationAndMapLinkFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :location, :string
    remove_column :events, :map_link, :string
  end
end
