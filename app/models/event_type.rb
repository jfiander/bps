class EventType < ApplicationRecord
  has_many   :events

  scope :advanced_grades, -> { where(event_category_id: category_hash[:advanced_grade]) }
  scope :electives,       -> { where(event_category_id: category_hash[:elective]) }
  scope :courses,         -> { public_courses.or(advanced_grades).or(electives) }
  scope :seminars,        -> { where(event_category_id: category_hash[:seminar]) }
  scope :public_courses,  -> { where(event_category_id: category_hash[:public]) }
  scope :events,          -> { where(event_category_id: category_hash[:meeting]) }
  scope :meetings,        -> { events }

  def display_title
    title.titleize.
      gsub(/americas/i, "America's").
      gsub(/commanders/i, "Commander's").
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
      meeting: 4,
      public: 5
    }
  end

  def self.course_category_ids
    [category_hash[:public], category_hash[:advanced_grade], category_hash[:elective]]
  end

  def self.filter_categories
    {
      course: [
        self.category_hash[:public],
        self.category_hash[:advanced_grade],
        self.category_hash[:elective],
      ],
      public: [
        self.category_hash[:public]
      ],
      advanced_grade: [
        self.category_hash[:advanced_grade]
      ],
      elective: [
        self.category_hash[:elective],
      ],
      seminar: [
        self.category_hash[:seminar]
      ],
      meeting: [
        self.category_hash[:meeting]
      ]
    }
  end
end
