class AddImportantNotesToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :important_notes, :text
  end
end
