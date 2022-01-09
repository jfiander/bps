class CreateCandidates < ActiveRecord::Migration[5.2]
  def change
    create_table :candidates do |t|
      t.integer :election_id
      t.string :description
      t.integer :user_id

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
