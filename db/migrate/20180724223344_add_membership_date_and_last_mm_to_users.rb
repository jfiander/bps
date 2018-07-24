class AddMembershipDateAndLastMmToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :membership_date, :datetime
    add_column :users, :last_mm, :datetime
  end
end
