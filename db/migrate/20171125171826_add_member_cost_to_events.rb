class AddMemberCostToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :member_cost, :integer
  end
end
