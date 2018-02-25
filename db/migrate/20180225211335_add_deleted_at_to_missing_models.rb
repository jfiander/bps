class AddDeletedAtToMissingModels < ActiveRecord::Migration[5.0]
  def change
    add_column :bridge_offices,    :deleted_at, :datetime
    add_column :course_includes,   :deleted_at, :datetime
    add_column :course_topics,     :deleted_at, :datetime
    add_column :event_instructors, :deleted_at, :datetime
  end
end
