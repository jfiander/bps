class EventType < ApplicationRecord
  belongs_to :event_category
  has_many   :events
end
