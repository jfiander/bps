class CreateFloatPlanOnboards < ActiveRecord::Migration[5.0]
  def change
    create_table :float_plan_onboards do |t|
      t.integer :float_plan_id
      t.string :name
      t.integer :age
      t.string :address
      t.string :phone

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
