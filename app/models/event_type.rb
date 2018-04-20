class EventType < ApplicationRecord
  has_many :events

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
  scope :ordered,         (lambda do
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
  end)

  validates :event_category, inclusion: %w[advanced_grade elective public seminar meeting]

  def self.selector(type)
    return seminars.ordered.map(&:to_select_array) if type == :seminar
    return meetings.ordered.map(&:to_select_array) if type == :event

    courses = []
    courses += select_array_section(:public_course, blank: false)
    courses += select_array_section(:advanced_grade)
    courses += select_array_section(:elective)
    courses
  end

  def self.select_array_section(scope, blank: true)
    (blank ? [['', '']] : []) +
      [["#{scope.to_s.titleize} Courses", '']] +
      [['-' * (scope.to_s.size + 10), '']] +
      send(scope).ordered.map(&:to_select_array)
  end

  def to_select_array
    [display_title, id]
  end

  def display_title
    cleanup_title(title.titleize)
  end

  def self.order_positions
    {
      'public' => 1,
      'advanced_grade' => {
        'seamanship' => 2,
        'piloting' => 3,
        'advanced_piloting' => 4,
        'junior_navigation' => 5,
        'navigation' => 6
      },
      'elective' => 7,
      'seminar' => 8,
      'meeting' => 9
    }
  end

  def order_position
    o = EventType.order_positions[event_category]
    o.is_a?(Hash) ? o[title] : o
  end

  def self.event
    meeting
  end

  private

  def cleanup_title(title)
    title_subs.each do |pattern, replacement|
      title.gsub!(/#{pattern}/i, replacement)
    end
    title
  end

  def title_subs
    possessives = {
      'americas' => "America's",
      'commanders' => "Commander's"
    }

    initials = {
      'gps' => 'GPS',
      'vhf' => 'VHF',
      'dsc' => 'DSC',
      'ais' => 'AIS',
      'pcoc' => 'PCOC'
    }

    small_words = {
      ' A ' => ' a ',
      ' To ' => ' to ',
      ' The ' => ' the ',
      ' Of ' => ' of ',
      ' And ' => ' and ',
      ' On ' => ' on ',
      ' In ' => ' in ',
      ' For ' => ' for '
    }

    [possessives, initials, small_words].inject(&:merge)
  end
end
