class CreateBallots < ActiveRecord::Migration[5.2]
  def change
    create_table :ballots do |t|
      t.integer :election_id
      t.integer :user_id

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
