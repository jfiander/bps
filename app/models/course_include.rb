class CourseInclude < ApplicationRecord
  belongs_to :course, class_name: "Event"
end
