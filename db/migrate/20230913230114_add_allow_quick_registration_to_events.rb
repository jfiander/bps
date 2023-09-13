class AddAllowQuickRegistrationToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :allow_quick_registration, :boolean, null: false, default: true
  end
end
