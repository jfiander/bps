# frozen_string_literal: true

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

  validates :event_category, inclusion: %w[advanced_grade elective public seminar meeting]

  before_save { self.title = title.downcase.tr(' ', '_') }

  def self.selector(type, key: false)
    seminars_select = seminars.ordered.map(&:to_select_array)
    meetings_select = meetings.ordered.map(&:to_select_array)
    return key ? { 'Seminars' => seminars_select } : seminars_select if type == 'seminar'
    return key ? { 'Events' => meetings_select } : meetings_select if type == 'event'

    course_selector_hash
  end

  def self.searchable
    all.map do |event_type|
      [event_type.event_category, event_type.title]
    end
  end

  def self.course_selector_hash
    {
      'Public' => public_course.ordered.map(&:to_select_array),
      'Advanced Grade' => advanced_grade.ordered.map(&:to_select_array),
      'Elective' => elective.ordered.map(&:to_select_array)
    }
  end

  def to_select_array
    [display_title, id]
  end

  def display_title
    cleanup_title(title)
  end

  def self.order_positions
    YAML.safe_load(File.read("#{Rails.root}/app/models/concerns/event_type/order.yml"))
  end

  def order_position
    o = EventType.order_positions[event_category]
    o.is_a?(Hash) ? o[title] : o
  end

  singleton_class.send(:alias_method, :event, :meeting)

private

  def cleanup_title(title)
    title = title.split('-').map(&:titleize).join('-')
    title_subs.each { |pattern, replacement| title.gsub!(/#{pattern}/i, replacement) }
    title
  end

  def title_subs
    # Configure acronyms in config/initializers/inflections.rb

    slashes = {
      'VHF DSC' => 'VHF/DSC', 'CPR AED' => 'CPR/AED'
    }

    small_words = {
      ' A ' => ' a ', ' To ' => ' to ', ' Of ' => ' of ', ' And ' => ' and ',
      ' On ' => ' on ', ' In ' => ' in ', ' For ' => ' for ', ' With ' => ' with ',
      '([- ])The([- ])' => '\1the\2'
    }

    [slashes, small_words].inject(&:merge)
  end
end
