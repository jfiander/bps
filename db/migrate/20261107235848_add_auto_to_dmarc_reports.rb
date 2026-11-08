class AddAutoToDmarcReports < ActiveRecord::Migration[8.1]
  def change
    add_column :dmarc_reports, :auto, :boolean, null: false, default: false
  end
end
