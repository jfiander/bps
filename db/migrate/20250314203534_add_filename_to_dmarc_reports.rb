class AddFilenameToDmarcReports < ActiveRecord::Migration[6.1]
  def change
    add_column :dmarc_reports, :filename, :string
  end
end
