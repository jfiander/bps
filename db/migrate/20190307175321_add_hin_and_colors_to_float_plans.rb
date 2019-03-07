class AddHinAndColorsToFloatPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :float_plans, :hin, :string
    add_column :float_plans, :deck_color, :string
    add_column :float_plans, :sail_color, :string
  end
end
