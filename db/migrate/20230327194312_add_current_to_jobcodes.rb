class AddCurrentToJobcodes < ActiveRecord::Migration[6.1]
  def change
    add_column :jobcodes, :current, :boolean, null: false, default: true
  end
end
