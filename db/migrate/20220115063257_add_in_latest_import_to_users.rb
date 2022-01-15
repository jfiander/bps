class AddInLatestImportToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :in_latest_import, :boolean
  end
end
