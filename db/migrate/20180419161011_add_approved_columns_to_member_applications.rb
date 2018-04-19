class AddApprovedColumnsToMemberApplications < ActiveRecord::Migration[5.0]
  def change
    add_column :member_applications, :approved_at, :datetime
    add_column :member_applications, :approver_id, :integer
  end
end
