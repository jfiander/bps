class CreateCourseCompletions < ActiveRecord::Migration[5.0]
  def change
    create_table :course_completions do |t|
      t.integer :user_id
      t.string :course_key
      t.datetime :date

      t.timestamps
    end
  end
end
