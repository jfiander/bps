class AddShowInCatalogToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :show_in_catalog, :boolean
  end
end
