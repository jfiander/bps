class AddSubscriptionTracking < ActiveRecord::Migration[5.2]
  def change
    add_column :registrations, :subscription_arn, :string
    add_column :users, :subscribe_on_register, :boolean, default: false, null: false
  end
end
