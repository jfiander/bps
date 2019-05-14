# frozen_string_literal: true

class Scheduled::Course < Scheduled::Base
  has_many   :course_topics,   foreign_key: :course_id, inverse_of: :course
  has_many   :course_includes, foreign_key: :course_id, inverse_of: :course
  belongs_to :prereq, class_name: 'EventType', optional: true

  has_many :event_instructors
  has_many :instructors, through: :event_instructors, source: :user

  def self.include_details
    includes(:event_type, :course_topics, :course_includes, :prereq)
  end

  def self.for_category(_ignored = nil)
    category = %w[public advanced_grade elective]
    includes(:event_type).where(event_types: { event_category: category })
  end
end
