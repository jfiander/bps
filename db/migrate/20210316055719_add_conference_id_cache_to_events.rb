class AddConferenceIdCacheToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :conference_id_cache, :string
  end
end
