class AddGoogleCalendarLinkToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :google_calendar_link, :string
  end
end
