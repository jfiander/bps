class CreateStandingCommitteeOffices < ActiveRecord::Migration[5.0]
  def change
    create_table :standing_committee_offices do |t|
      t.string :committee_name
      t.integer :user_id
      t.datetime :term_start_at
      t.integer :term_length
      t.datetime :term_expires_at
      t.boolean :chair

      t.timestamps
    end
  end
end
