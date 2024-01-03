class AddIndefiniteToStandingCommitteeOffices < ActiveRecord::Migration[6.1]
  def change
    add_column :standing_committee_offices, :indefinite, :boolean, default: false, null: false
  end
end
