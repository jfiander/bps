class AddPdfToFloatPlans < ActiveRecord::Migration[5.0]
  def up
    add_attachment :float_plans, :pdf
  end

  def down
    remove_attachment :float_plans, :pdf
  end
end
