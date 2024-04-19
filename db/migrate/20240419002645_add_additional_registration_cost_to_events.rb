class AddAdditionalRegistrationCostToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :additional_registration_cost, :integer
  end
end
