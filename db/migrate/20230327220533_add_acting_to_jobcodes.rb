class AddActingToJobcodes < ActiveRecord::Migration[6.1]
  def change
    add_column :jobcodes, :acting, :boolean, null: false, default: false
  end
end
