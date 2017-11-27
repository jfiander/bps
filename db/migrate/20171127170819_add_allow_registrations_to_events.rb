class AddAllowRegistrationsToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :allow_member_registrations, :boolean, default: true
    add_column :events, :allow_public_registrations, :boolean, default: true
  end
end
