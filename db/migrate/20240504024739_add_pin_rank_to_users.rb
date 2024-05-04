class AddPinRankToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :preferred_pin_rank, :string
  end
end
