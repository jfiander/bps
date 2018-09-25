class AddRegistrationLimitToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :registration_limit, :integer
  end
end
