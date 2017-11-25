class EventCategory < ApplicationRecord
  has_many :event_types
  has_many :events

  scope :courses,  -> { where(title: ["advanced_grade", "elective"]) }
  scope :seminars, -> { where(title: ["seminar"]) }
  scope :events,   -> { where(title: ["meeting"]) }
end
