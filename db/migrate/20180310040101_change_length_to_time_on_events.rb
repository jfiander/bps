class ChangeLengthToTimeOnEvents < ActiveRecord::Migration[5.0]
  def up
    change_column :events, :length, :time
  end

  def down
    change_column :events, :length, :datetime
  end
end
