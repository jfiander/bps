class EventCategory < ApplicationRecord
  has_many :event_types
  has_many :events
end
