class Event < ApplicationRecord
  belongs_to :event_type
  has_many   :course_topics
  has_many   :course_includes
  has_one    :prereq, class_name: "Event"
end
