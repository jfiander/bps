class ChangeLengthToDatetimeOnEvents < ActiveRecord::Migration[5.0]
  def up
    remove_column :events, :length
    add_column :events, :length, :datetime
  end

  def down
    remove_column :events, :length
    add_column :events, :length, :integer
  end
end
