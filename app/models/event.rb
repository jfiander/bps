# frozen_string_literal: true

class Event < ApplicationRecord
  include Concerns::Event::Calendar
  include Concerns::Event::Category
  include Concerns::Event::Flyer
  include Concerns::Event::Boolean

  belongs_to :event_type
  has_many   :course_topics,   foreign_key: :course_id
  has_many   :course_includes, foreign_key: :course_id
  belongs_to :prereq, class_name: 'EventType', optional: true
  belongs_to :location, optional: true

  has_many :event_instructors
  has_many :instructors, through: :event_instructors, source: :user

  has_many :registrations

  before_validation { validate_costs }

  after_create { book! if ENV['ASSET_ENVIRONMENT'] == 'production' }
  before_destroy { unbook! if ENV['ASSET_ENVIRONMENT'] == 'production' }

  has_attached_file(
    :flyer,
    paperclip_defaults(:files).merge(path: 'event_flyers/:id/:filename')
  )

  validates_attachment_content_type(
    :flyer,
    content_type: %r{\A(image/(jpe?g|png|gif))|(application/pdf)\z}
  )

  validates :event_type, :start_at, :expires_at, :cutoff_at, presence: true

  def self.include_details
    includes(:event_type, :course_topics, :course_includes, :prereq)
  end

  def self.for_category(category)
    where(event_type: EventType.send(category))
  end

  def self.current(category)
    include_details.for_category(category).where('expires_at > ?', Time.now)
  end

  def self.all_expired(category)
    include_details.for_category(category).where('expires_at <= ?', Time.now)
  end

  def self.expired(category)
    all_expired(category)
      .where('start_at >= ?', Date.today.last_year.beginning_of_year)
  end

  def self.with_registrations
    includes(:registrations).select { |e| e.registrations.present? }
  end

  def formatted_cost
    # html_safe: User content is restricted to integers
    return nil if cost.blank?
    return "<b>Cost:</b> $#{cost}".html_safe if member_cost.blank?
    "<b>Members:</b> $#{member_cost}, <b>Non-members:</b> $#{cost}".html_safe
  end

  def formatted_length
    return nil if length.blank?

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

  private

  def validate_costs
    return unless member_cost.present?
    return if cost.present? && cost > member_cost

    self.cost = member_cost
    self.member_cost = nil
  end
end
