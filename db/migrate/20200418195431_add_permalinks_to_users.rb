class AddPermalinksToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :permalinks, :boolean, default: :false
  end
end
