# frozen_string_literal: true

class CourseCompletion < ApplicationRecord
  belongs_to :user

  validates :course_key, presence: true
  validates :date, presence: true

  default_scope { order('date ASC') }

  def to_h
    { course_key => date.strftime('%Y-%m-%d') }
  end
end
