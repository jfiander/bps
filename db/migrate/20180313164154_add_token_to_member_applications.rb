class AddTokenToMemberApplications < ActiveRecord::Migration[5.0]
  def change
    add_column :member_applications, :token, :string
  end
end
