class CreateAwardRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :award_recipients do |t|
      t.string :award_name
      t.date :year
      t.integer :user_id
      t.integer :additional_user_id
      t.string :name
      t.attachment :photo
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
