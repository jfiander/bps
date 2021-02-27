class AddIconToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :icon, :string
  end
end
