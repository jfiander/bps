# frozen_string_literal: true

class Event < ApplicationRecord
  include Concerns::Event::Calendar
  include Concerns::Event::Category
  include Concerns::Event::Flyer
  include Concerns::Event::Boolean
  include Concerns::Event::Cost

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

  scope :displayable, -> { where(archived_at: nil) }

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

  validates_attachment_content_type(
    :flyer, content_type: %r{\A(image/(jpe?g|png|gif))|(application/pdf)\z}
  )

  before_save :refresh_calendar!, if: :calendar_details_updated?
  after_create { book! }
  before_destroy { unbook! }

  def self.include_details
    includes(:event_type, :course_topics, :course_includes, :prereq)
  end

  def self.for_category(category)
    category = %w[public advanced_grade elective] if category.to_s == 'course'
    includes(:event_type).where(event_types: { event_category: category })
  end

  def self.current(category)
    include_details.for_category(category).where('expires_at > ?', Time.now)
  end

  def self.all_expired(category)
    include_details.for_category(category).where('expires_at <= ?', Time.now)
  end

  def self.expired(category)
    all_expired(category).where('start_at >= ?', Date.today.last_year.beginning_of_year)
  end

  def self.with_registrations
    includes(:registrations).select { |e| e.registrations.present? }
  end

  def formatted_length
    return if length.blank?

    hour = length.hour
    min = length.min
    hours = "#{hour} #{'hour'.pluralize(hour)}"
    mins = " #{min} #{'min'.pluralize(min)}" unless min.zero?
    "#{hours}#{mins}"
  end

  def register_user(user)
    Registration.create(user: user, event: self)
  end

  def assign_instructor(user)
    EventInstructor.create(event: self, user: user)
  end

  def remind!
    return if reminded?

    registrations.each { |reg| RegistrationMailer.remind(reg).deliver }
    update(reminded_at: Time.now)
  end

  def expire!
    update(expires_at: Time.now)
  end

  def archive!
    update(archived_at: Time.now)
  end

  def link
    return if id.blank?

    route = category == 'meeting' ? 'event' : category
    Rails.application.routes.url_helpers.send("show_#{route}_url", id, host: ENV['DOMAIN'])
  end

  def display_title(event_type_cache = nil)
    return summary if summary.present?

    event_type_cache ||= event_type
    event_type_cache.display_title
  end

  def date_title(event_type_cache = nil)
    "#{display_title(event_type_cache)} – #{start_at.strftime(ApplicationController::SIMPLE_DATE_FORMAT)}"
  end

  def repeat_description
    repeat_pattern == 'DAILY' ? 'over consecutive days' : 'every week'
  end

  def attach_promo_code(code, **args)
    promo_code = PromoCode.find_or_create_by(code: code, **args)

    unless (epc = EventPromoCode.find_by(event: self, promo_code: promo_code))
      epc = EventPromoCode.create(event: self, promo_code: promo_code)
    end

    epc
  end

private

  def validate_dates
    self.cutoff_at = start_at if cutoff_at.blank?
    self.expires_at = start_at + 1.week if expires_at.blank?
  end
end
