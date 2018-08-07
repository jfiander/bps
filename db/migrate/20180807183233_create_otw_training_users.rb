class CreateOTWTrainingUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :otw_training_users do |t|
      t.integer :otw_training_id
      t.integer :user_id
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
