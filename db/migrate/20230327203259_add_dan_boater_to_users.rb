class AddDanBoaterToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :dan_boater, :boolean, null: false, default: false
  end
end
