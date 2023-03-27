class CreateJobcodes < ActiveRecord::Migration[6.1]
  def change
    create_table :jobcodes do |t|
      t.integer :user_id
      t.string :code
      t.integer :year
      t.string :description

      t.timestamps

      t.datetime :deleted_at
    end

    add_index :jobcodes, %i[user_id code year], unique: true, name: 'user_job_year'
  end
end
