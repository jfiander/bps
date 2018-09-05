class CreateImportLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :import_logs do |t|
      t.text :json
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
