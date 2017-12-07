class EventType < ApplicationRecord
  has_many   :events

  scope :advanced_grades, -> { where(event_category: :advanced_grade) }
  scope :electives,       -> { where(event_category: :elective) }
  scope :public_courses,  -> { where(event_category: :public) }
  scope :courses,         -> { public_courses.or(advanced_grades).or(electives) }
  scope :seminars,        -> { where(event_category: :seminar) }
  scope :events,          -> { where(event_category: :meeting) }
  scope :meetings,        -> { events }
  scope :advanced_grade,  -> { advanced_grades }
  scope :elective,        -> { electives }
  scope :public_course,   -> { public_courses }
  scope :course,          -> { courses }
  scope :seminar,         -> { seminars }
  scope :meeting,         -> { meetings }

  scope :ordered,         -> {
    order <<~SQL
      CASE
        WHEN event_category = 'public'     THEN '1' || title
        WHEN event_category = 'advanced_grade' THEN CASE
          WHEN title = 'seamanship'        THEN '2'
          WHEN title = 'piloting'          THEN '3'
          WHEN title = 'advanced_piloting' THEN '4'
          WHEN title = 'junior_navigation' THEN '5'
          WHEN title = 'navigation'        THEN '6'
        END
        WHEN event_category = 'elective'   THEN '7' || title
        WHEN event_category = 'seminar'    THEN '8' || title
        WHEN event_category = 'meeting'    THEN '9' || title
      END
    SQL
  }
  
  def self.selector(type)
    return self.seminars.ordered.map(&:to_select_array) if type == :seminar
    return self.meetings.ordered.map(&:to_select_array) if type == :meeting

    courses = []
    courses += [["Public Courses", ""]]
    courses += [["--------------", ""]]
    courses += public_courses.ordered.map(&:to_select_array)
    courses += [["", ""]]
    courses += [["Advanced Grade Courses", ""]]
    courses += [["----------------------", ""]]
    courses += advanced_grades.ordered.map(&:to_select_array)
    courses += [["", ""]]
    courses += [["Elective Courses", ""]]
    courses += [["----------------", ""]]
    courses += electives.ordered.map(&:to_select_array)
    courses
  end

  def to_select_array
    [display_title, id]
  end

  def display_title
    cleanup_titles(title.titleize)
  end

  private
  def cleanup_titles(title)
    title_hash.each do |k,v|
      title.gsub!(/#{k}/i, v)
    end
    title
  end

  def title_hash
    possessives = {
      "americas" => "America's",
      "commanders" => "Commander's"
    }

    initials = {
      "gps" => "GPS",
      "vhf" => "VHF",
      "dsc" => "DSC",
      "pcoc" => "PCOC"
    }

    small_words = {
      " A " => " a ",
      " To " => " to ",
      " The " => " the ",
      " Of " => " of ",
      " And " => " and ",
      " On " => " on ",
      " For " => " for "
    }

    possessives.merge(initials).merge(small_words)
  end
end
