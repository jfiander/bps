class CreateEventTypeCommittees < ActiveRecord::Migration[5.2]
  def change
    create_table :event_type_committees do |t|
      t.integer :event_type_id
      t.string :committee
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
