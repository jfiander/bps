class RemovePaidColumnsFromRegistrationsAndMemberApplications < ActiveRecord::Migration[5.0]
  def up
    remove_column :registrations, :paid_at
    remove_column :registrations, :paid
    remove_column :registrations, :token
    remove_column :registrations, :transaction_id

    remove_column :member_applications, :paid_at
    remove_column :member_applications, :paid
    remove_column :member_applications, :token
    remove_column :member_applications, :transaction_id
  end
end
