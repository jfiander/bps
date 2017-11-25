class Event < ApplicationRecord
  belongs_to :event_type
  has_many   :course_topics
  has_many   :course_includes
  has_one    :prereq, class_name: "Event"
  
  scope :current, ->(category) { where.not("expires_at < ?", Time.now).find_all { |e| e.event_category == EventCategory.find_by(title: category.to_s) } }

  def event_category
    event_type.event_category
  end
end
