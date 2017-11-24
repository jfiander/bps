class AddCourseKeyToEventTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :event_types, :course_key, :string
  end
end
