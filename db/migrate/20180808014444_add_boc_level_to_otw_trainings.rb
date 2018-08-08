class AddBocLevelToOTWTrainings < ActiveRecord::Migration[5.2]
  def change
    add_column :otw_trainings, :boc_level, :string
  end
end
