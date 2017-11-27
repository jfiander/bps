class SimplifyEventCategory < ActiveRecord::Migration[5.0]
  def up
    remove_column :events, :event_category_id
    drop_table :event_categories
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
