class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.integer :ballot_id
      t.string :selection
      t.integer :preference

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
