class AddVisibleToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :visible, :boolean, default: true, null: false
  end
end
