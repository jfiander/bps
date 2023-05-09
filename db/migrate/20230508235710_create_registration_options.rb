class CreateRegistrationOptions < ActiveRecord::Migration[6.1]
  def change
    create_table :event_selections do |t|
      t.integer :event_id
      t.string :description

      t.timestamps
      t.timestamp :deleted_at
    end

    create_table :event_options do |t|
      t.integer :event_selection_id
      t.string :name

      t.timestamps
      t.timestamp :deleted_at
    end

    create_table :registration_options do |t|
      t.integer :registration_id
      t.integer :event_option_id
      t.string :selection

      t.timestamps
      t.timestamp :deleted_at
    end
  end
end
