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
