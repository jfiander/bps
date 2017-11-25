class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :registrations do |t|
      t.integer :user_id
      t.string :email
      t.integer :event_id
      t.boolean :paid
      t.datetime :paid_at

      t.timestamps
    end
  end
end
