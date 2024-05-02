class AddFlagRankAndStripeRankToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :preferred_flag_rank, :string
    add_column :users, :preferred_stripe_rank, :string
  end
end
