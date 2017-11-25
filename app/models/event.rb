class Event < ApplicationRecord
  belongs_to :event_type
  has_many   :course_topics
  has_many   :course_includes
  has_one    :prereq, class_name: "Event"
  
  scope :current, ->(category) { where(event_category: EventCategory.find_by(title: category.to_s)).where.not("expires_at < ?", Time.now) }
end
