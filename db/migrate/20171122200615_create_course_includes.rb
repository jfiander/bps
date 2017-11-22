class CreateCourseIncludes < ActiveRecord::Migration[5.0]
  def change
    create_table :course_includes do |t|
      t.integer :course_id
      t.string :text

      t.timestamps
    end
  end
end
