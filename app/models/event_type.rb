class EventType < ApplicationRecord
  has_many   :events

  scope :advanced_grades, -> { where(event_category_id: category_hash[:advanced_grade]) }
  scope :electives,       -> { where(event_category_id: category_hash[:elective]) }
  scope :courses,         -> { advanced_grades.or(electives) }
  scope :seminars,        -> { where(event_category_id: category_hash[:seminar]) }
  scope :events,          -> { where(event_category_id: category_hash[:meeting]) }

  def display_title
    title.titleize.
      gsub(/gps/i, "GPS").
      gsub(/vhf/i, "VHF").
      gsub(/dsc/i, "DSC").
      gsub(/ A /, " a ").
      gsub(/ To /, " to ").
      gsub(/ The /, " the ").
      gsub(/ Of /, " of ").
      gsub(/ And /, " and ").
      gsub(/ On /, " on ").
      gsub(/ For /, " for ")
  end

  def self.category_hash
    {
      advanced_grade: 1,
      elective: 2,
      seminar: 3,
      meeting: 4
    }
  end

  def self.course_category_ids
    [category_hash[:advanced_grade], category_hash[:elective]]
  end
end
