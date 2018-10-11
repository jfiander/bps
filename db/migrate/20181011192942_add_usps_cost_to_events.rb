class AddUSPSCostToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :usps_cost, :integer
  end
end
