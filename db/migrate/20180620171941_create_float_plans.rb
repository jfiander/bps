class CreateFloatPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :float_plans do |t|
      t.string :name
      t.string :phone
      t.string :boat_type
      t.string :subtype
      t.string :hull_color
      t.string :trim_color
      t.string :registration_number
      t.integer :length
      t.string :boat_name
      t.string :make
      t.string :model
      t.string :year
      t.string :engine_type_1
      t.string :engine_type_2
      t.integer :horse_power
      t.integer :number_of_engines
      t.integer :fuel_capacity
      t.boolean :pfds
      t.boolean :flares
      t.boolean :mirror
      t.boolean :horn
      t.boolean :smoke
      t.boolean :flashlight
      t.boolean :raft
      t.boolean :epirb
      t.boolean :paddles
      t.boolean :food
      t.boolean :water
      t.boolean :anchor
      t.boolean :epirb_16
      t.boolean :epirb_1215
      t.boolean :epirb_406
      t.string :radio
      t.boolean :radio_vhf
      t.boolean :radio_ssb
      t.boolean :radio_cb
      t.boolean :radio_cell_phone
      t.string :channels_monitored
      t.string :call_sign
      t.string :leave_from
      t.string :going_to
      t.datetime :leave_at
      t.datetime :return_at
      t.datetime :alert_at
      t.text :comments
      t.string :car_make
      t.string :car_model
      t.string :car_year
      t.string :car_color
      t.string :car_license_plate
      t.string :trailer_license_plate
      t.string :car_parked_at
      t.string :alert_name
      t.string :alert_phone

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
