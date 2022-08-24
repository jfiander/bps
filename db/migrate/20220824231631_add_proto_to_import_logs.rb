class AddProtoToImportLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :import_logs, :proto, :binary
  end
end
