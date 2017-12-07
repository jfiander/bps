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
    cleanup_titles(title.titleize)
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
