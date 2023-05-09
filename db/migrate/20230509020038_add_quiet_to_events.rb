class AddQuietToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :quiet, :boolean, null: false, default: false
  end
end
