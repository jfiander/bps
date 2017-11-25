class AddEventCategoryIdToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :event_category_id, :integer
  end
end
