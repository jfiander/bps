# frozen_string_literal: true

class CourseTopic < ApplicationRecord
  belongs_to :course, class_name: 'Event'
end
