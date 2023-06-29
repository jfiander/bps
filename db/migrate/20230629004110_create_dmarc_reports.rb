class CreateDmarcReports < ActiveRecord::Migration[6.1]
  def change
    create_table :dmarc_reports do |t|
      t.text :xml

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
