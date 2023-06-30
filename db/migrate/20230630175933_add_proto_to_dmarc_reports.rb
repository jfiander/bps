class AddProtoToDmarcReports < ActiveRecord::Migration[6.1]
  def change
    add_column :dmarc_reports, :proto, :binary
  end
end
