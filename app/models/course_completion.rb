# frozen_string_literal: true

class CourseCompletion < ApplicationRecord
  belongs_to :user

  validates :course_key, presence: true
  validates :date, presence: true

  default_scope { order('date ASC') }

  scope :by_user, -> { group_by(&:user) }
  scope :ytd, -> { where('date > ?', Date.today.beginning_of_year) }
  scope :with_users, -> { includes(user: User.position_associations) }

  def to_h
    { course_key => date.strftime('%Y-%m-%d') }
  end
end
