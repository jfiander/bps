class AddCutoffAtToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :cutoff_at, :datetime
  end
end
