class AddPrereqIdToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :prereq_id, :integer
  end
end
