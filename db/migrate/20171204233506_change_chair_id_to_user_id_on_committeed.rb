class ChangeChairIdToUserIdOnCommitteed < ActiveRecord::Migration[5.0]
  def change
    rename_column :committees, :chair_id, :user_id
  end
end
