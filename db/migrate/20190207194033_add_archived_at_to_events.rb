class AddArchivedAtToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :archived_at, :datetime
  end
end
