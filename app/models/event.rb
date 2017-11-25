class Event < ApplicationRecord
  belongs_to :event_type
  belongs_to :event_category
  has_many   :course_topics
  has_many   :course_includes
  has_one    :prereq, class_name: "Event"

  before_save { self.event_category = self.event_type.event_category }
  
  scope :current, ->(category) { where.not("expires_at < ?", Time.now).find_all { |e| e.event_category == EventCategory.find_by(title: category.to_s) } }

  def is_a_course?
    event_category&.title.in? ["advanced_grade", "elective"]
  end
end
