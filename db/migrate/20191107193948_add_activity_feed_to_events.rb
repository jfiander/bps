class AddActivityFeedToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :activity_feed, :boolean
  end
end
