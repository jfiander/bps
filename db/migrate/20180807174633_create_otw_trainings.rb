class CreateOTWTrainings < ActiveRecord::Migration[5.2]
  def change
    create_table :otw_trainings do |t|
      t.string :name
      t.string :description
      t.string :course_key
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
