class ChangeCourseTypeToEventTypeOnEvents < ActiveRecord::Migration[5.0]
  def change
    rename_column :events, :course_type_id, :event_type_id
  end
end
