class UpdateFlyerOnEvents < ActiveRecord::Migration[5.0]
  def up
    remove_column :events, :flyer_link
    add_attachment :events, :flyer
  end

  def down
    add_column :events, :flyer_link, :string
    remove_attachment :events, :flyer
  end
end
