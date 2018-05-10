class AddPaidColumnsToMemberApplications < ActiveRecord::Migration[5.0]
  def change
    add_column :member_applications, :paid_at, :datetime
    add_column :member_applications, :paid, :string
    add_column :member_applications, :transaction_id, :string
  end
end
