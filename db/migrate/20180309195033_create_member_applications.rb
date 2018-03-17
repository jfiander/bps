class CreateMemberApplications < ActiveRecord::Migration[5.0]
  def change
    create_table :member_applications do |t|
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
