class SetStandingCommitteeChairDefault < ActiveRecord::Migration[5.2]
  def up
    StandingCommitteeOffice.where(chair: nil).update_all(chair: false)
    change_column :standing_committee_offices, :chair, :boolean, default: false
  end

  def down
    change_column :standing_committee_offices, :chair, :boolean, default: nil
  end
end
