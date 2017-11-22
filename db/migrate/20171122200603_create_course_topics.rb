class CreateCourseTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :course_topics do |t|
      t.integer :course_id
      t.string :text

      t.timestamps
    end
  end
end
