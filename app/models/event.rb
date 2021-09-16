# frozen_string_literal: true

class Event < ApplicationRecord
  COURSE_CATEGORIES = %w[public advanced_grade elective].freeze

  include Concerns::Event::Calendar
  include Concerns::Event::Category
  include Concerns::Event::Flyer
  include Concerns::Event::Boolean
  include Concerns::Event::Cost
  include Concerns::Event::Actions

  belongs_to :event_type
  has_many   :course_topics,   foreign_key: :course_id, inverse_of: :course
  has_many   :course_includes, foreign_key: :course_id, inverse_of: :course
  belongs_to :prereq, class_name: 'EventType', optional: true
  belongs_to :location, optional: true
  has_many :event_promo_codes
  has_many :promo_codes, through: :event_promo_codes

  has_many :event_instructors
  has_many :instructors, through: :event_instructors, source: :user

  has_many :registrations

  scope :by_date, -> { order(:start_at) }
  scope :displayable, -> { where(archived_at: nil).where('start_at > ?', Event.auto_archive) }
  scope :current, -> { where('expires_at > ?', Time.now) }
  scope :expired, -> { where('expires_at <= ?', Time.now) }
  scope(:activity_feed, lambda do
    where('start_at > ? AND expires_at > ? AND activity_feed = ?', Time.now, Time.now, true)
  end)

  has_attached_file(
    :flyer, paperclip_defaults(:files).merge(path: 'event_flyers/:id/:filename')
  )

  attr_accessor :delete_attachment, :calendar_attributes

  before_validation do
    validate_costs
    validate_dates
    flyer.clear if delete_attachment == '1'
  end

  validates :repeat_pattern, inclusion: { in: %w[DAILY WEEKLY] << nil }
  validates :event_type, :start_at, :expires_at, :cutoff_at, presence: true
  validates :slug, uniqueness: true, if: -> { slug.present? }

  validates_attachment_content_type(
    :flyer, content_type: %r{\A(image/(jpe?g|png|gif))|(application/pdf)\z}
  )

  before_save { self.slug = slug.downcase.tr('/', '_') if slug.present? }
  before_destroy :unbook!

  after_create :book!
  after_create :create_sns_topic!
  after_commit :refresh_calendar!, if: :calendar_details_updated?

  def self.auto_archive
    Date.today.last_year.beginning_of_year
  end

  def self.fetch(category, expired: false, flat: false)
    scope = expired ? :expired : :current
    include_details.displayable.send(scope).by_date.for_category(category, flat: flat)
  end

  def self.catalog(category)
    include_details.where(show_in_catalog: true).order(EventType.order_sql).for_category(category)
  end

  def self.include_details
    includes(
      :event_type, :course_topics, :course_includes, :prereq, :location,
      event_instructors: { user: User.position_associations },
      registrations: { user: User.position_associations }
    )
  end

  def self.for_category(category, flat: false)
    events = includes(:event_type).where(event_types: { event_category: query_category(category) })
    return events if category != 'course' || flat

    # Group by course category, and ensure all categories exist, in the correct order.
    grouped = events.group_by { |e| e.event_type.event_category }
    COURSE_CATEGORIES.each_with_object({}) { |k, h| h[k.to_sym] = grouped[k] || [] }
  end

  def self.query_category(category)
    case category.to_s
    when 'course'
      COURSE_CATEGORIES
    when 'event'
      'meeting'
    else
      category
    end
  end

  def self.fetch_activity_feed
    include_details.activity_feed.order(:start_at).first(ENV['ACTIVITY_FEED_LENGTH'].to_i)
  end

  def self.with_registrations
    includes(:registrations).select { |e| e.registrations.present? }
  end

  def length
    hour = length_h.to_s.rjust(2, '0')
    min = length_m.present? ? length_m.to_s.rjust(2, '0') : '00'
    Time.strptime("#{hour}#{min} UTC", '%H%M %Z')
  end

  def formatted_length
    return unless length?

    hour = length.hour
    min = length.min
    hours = "#{hour} #{'hour'.pluralize(hour)}"
    mins = " #{min} #{'min'.pluralize(min)}" unless min.zero?
    "#{hours}#{mins}"
  end

  def public_link
    Rails.application.routes.url_helpers.send(*public_link_path, host: ENV['DOMAIN'])
  end

  def link
    return if id.blank?

    route = category == 'meeting' ? 'event' : category
    Rails.application.routes.url_helpers.send("show_#{route}_url", id, host: ENV['DOMAIN'])
  end

  def path
    return if id.blank?

    route = category == 'meeting' ? 'event' : category
    Rails.application.routes.url_helpers.send("show_#{route}_path", id)
  end

  def display_title(event_type_cache = nil)
    return summary if summary.present?

    event_type_cache ||= event_type
    event_type_cache.display_title
  end

  def date_title(event_type_cache = nil)
    start_at_formatted = start_at.strftime(TimeHelper::FULL_DATE)
    "#{display_title(event_type_cache)} – #{start_at_formatted}"
  end

  def repeat_description
    repeat_pattern == 'DAILY' ? 'over consecutive days' : 'every week'
  end

  def create_sns_topic!
    return true if topic_arn.present?
    return false if Rails.env.development?

    arn = BpsSMS.create_topic("event_#{id}", date_title).topic_arn
    update(topic_arn: arn)
  end

private

  def validate_dates
    return unless start_at.present?

    self.cutoff_at = start_at if cutoff_at.blank? || out_of_date(:cutoff_at)
    self.expires_at = start_at + 1.week if expires_at.blank? || out_of_date(:expires_at)
  end

  def out_of_date(field)
    start_at_changed? && !send("#{field}_changed?")
  end

  def public_link_path
    if slug.present?
      ['event_slug_url', slug]
    elsif id.present?
      route = meeting? ? 'event' : category
      ["show_#{route}_url", id]
    end
  end
end
