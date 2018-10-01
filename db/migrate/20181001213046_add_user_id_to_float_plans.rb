class AddUserIdToFloatPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :float_plans, :user_id, :integer
  end
end
