class ChangeCategoryTypeIdOnEventTypes < ActiveRecord::Migration[5.0]
  def up
    change_column :event_types, :event_category_id, :string
    rename_column :event_types, :event_category_id, :event_category
  end

  def down
    rename_column :event_types, :event_category, :event_category_id
    change_column :event_types, :event_category_id, :integer
  end
end
