class AddSourcesProtoToDmarcReports < ActiveRecord::Migration[6.1]
  def change
    add_column :dmarc_reports, :sources_proto, :binary
  end
end
