class AddOverrideCommentToRegistrations < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :override_comment, :string
  end
end
