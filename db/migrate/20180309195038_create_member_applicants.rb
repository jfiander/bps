class CreateMemberApplicants < ActiveRecord::Migration[5.0]
  def change
    create_table :member_applicants do |t|
      t.integer :member_application_id
      t.boolean :primary
      t.string :member_type
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.date :dob
      t.string :gender
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone_h
      t.string :phone_c
      t.string :phone_w
      t.string :fax
      t.string :email
      t.boolean :sea_scout
      t.string :sig_other_name
      t.string :boat_type
      t.string :boat_length
      t.string :boat_name
      t.string :previous_certificate
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
