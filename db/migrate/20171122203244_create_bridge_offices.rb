class CreateBridgeOffices < ActiveRecord::Migration[5.0]
  def change
    create_table :bridge_offices do |t|
      t.string :office
      t.integer :user_id

      t.timestamps
    end
  end
end
