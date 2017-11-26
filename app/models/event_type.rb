class EventType < ApplicationRecord
  belongs_to :event_category
  has_many   :events

  def display_title
    title.titleize.
      gsub(/gps/i, "GPS").
      gsub(/vhf/i, "VHF").
      gsub(/dsc/i, "DSC").
      gsub(/ A /, " a ").
      gsub(/ To /, " to ").
      gsub(/ The /, " the ").
      gsub(/ Of /, " of ").
      gsub(/ And /, " and ").
      gsub(/ On /, " on ").
      gsub(/ For /, " for ")
  end
end
