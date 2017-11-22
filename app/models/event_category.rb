class EventCategory < ApplicationRecord
  has_many :event_types
end
