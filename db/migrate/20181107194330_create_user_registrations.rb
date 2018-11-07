# frozen_string_literal: true

class CreateUserRegistrations < ActiveRecord::Migration[5.2]
  def up
    create_table :user_registrations do |t|
      t.integer :registration_id
      t.integer :user_id
      t.string :email
      t.boolean :primary
      t.datetime :deleted_at

      t.timestamps
    end

    Registration.with_deleted.all.each do |reg|
      UserRegistration.new(
        registration: reg, primary: true, user_id: reg.user_id, email: reg.email
      ).save(validate: false)
    end

    remove_column :registrations, :user_id
    remove_column :registrations, :email
  end

  def down
    add_column :registrations, :user_id, :string
    add_column :registrations, :email, :string

    UserRegistration.with_deleted.where(primary: true).each do |ur|
      ur.registration.user_id = ur.user_id
      ur.registration.email = ur.email
      ur.registration(validate: false)
    end

    drop_table :user_registrations
  end
end
