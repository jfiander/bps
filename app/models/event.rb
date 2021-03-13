# frozen_string_literal: true

class Event < ApplicationRecord
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

  default_scope { order(:start_at) }

  scope :displayable, -> { where(archived_at: nil).where('start_at > ?', Event.auto_archive) }
  scope :current, -> { where('expires_at > ?', Time.now) }
  scope :expired, -> { where('expires_at <= ?', Time.now) }

  has_attached_file(
    :flyer, paperclip_defaults(:files).merge(path: 'event_flyers/:id/:filename')
  )

  attr_accessor :delete_attachment

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

  def self.include_details
    includes(
      :event_type, :course_topics, :course_includes, :prereq, :location,
      instructors: User.position_associations, registrations: :payment
    )
  end

  def self.for_category(category)
    category = case category.to_s
               when 'course'
                 %w[public advanced_grade elective]
               when 'event'
                 'meeting'
               else
                 category
               end
    includes(:event_type).where(event_types: { event_category: category })
  end

  # def self.current(category)
  #   include_details.for_category(category).where('expires_at > ?', Time.now)
  # end

  # def self.all_expired(category)
  #   include_details.for_category(category).where('expires_at <= ?', Time.now)
  # end

  # def self.expired(category)
  #   all_expired(category).where('start_at >= ?', Date.today.last_year.beginning_of_year)
  # end

  def self.activity_feed
    include_details.order(:start_at).where('expires_at > ? AND activity_feed = ?', Time.now, true)
  end

  def self.with_registrations
    includes(:registrations).select { |e| e.registrations.present? }
  end

  def length
    hour = length_h.to_s.rjust(2, '0')
    min = length_m.present? ? length_m.to_s.rjust(2, '0') : '00'
    Time.strptime("#{hour}#{min}", '%H%M')
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
    start_at_formatted = start_at.strftime(ApplicationController::SIMPLE_DATE_FORMAT)
    "#{display_title(event_type_cache)} – #{start_at_formatted}"
  end

  def repeat_description
    repeat_pattern == 'DAILY' ? 'over consecutive days' : 'every week'
  end

  def create_sns_topic!
    return true if topic_arn.present?

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
    start_at_changed? && !send("#{field}_changed?") && send(field) < start_at
  end

  def public_link_path
    if slug.present?
      ['event_slug_url', slug]
    elsif id.present?
      route = category == 'meeting' ? 'event' : category
      ["show_#{route}_url", id]
    end
  end
end
