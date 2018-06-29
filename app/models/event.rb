# frozen_string_literal: true

class Event < ApplicationRecord
  include Concerns::Event::Calendar

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

  scope :current, (lambda do |category|
    includes(:event_type, :course_topics, :course_includes, :prereq)
      .where('expires_at > ?', Time.now)
      .where(event_type: EventType.send(category))
  end)

  scope :expired, (lambda do |category|
    includes(:event_type, :course_topics, :course_includes, :prereq)
      .where('expires_at <= ?', Time.now)
      .where(event_type: EventType.send(category))
  end)

  scope :with_registrations, (lambda do
    includes(:registrations).select { |e| e.registrations.present? }
  end)

  def expired?
    expires_at.present? && expires_at < Time.now
  end

  def cutoff?
    cutoff_at.present? && cutoff_at < Time.now
  end

  def category(event_types = nil)
    if event_types.present?
      load_event_type_ids_from_cache(event_types)
    else
      @course_ids = EventType.courses.map(&:id)
      @seminar_ids = EventType.seminars.map(&:id)
      @meeting_ids = EventType.meetings.map(&:id)
    end

    return :course if event_type_id.in? @course_ids
    return :seminar if event_type_id.in? @seminar_ids
    return :event if event_type_id.in? @meeting_ids
  end

  def category?(cat, event_types = nil)
    category(event_types) == cat.to_sym
  end

  def course?(event_types = nil)
    category?(:course, event_types)
  end

  def seminar?(event_types = nil)
    category?(:seminar, event_types)
  end

  def meeting?(event_types = nil)
    category?(:meeting, event_types)
  end

  def length?
    length.present? && length&.strftime('%-kh %Mm') != '0h 00m'
  end

  def multiple_sessions?
    sessions.present? && sessions > 1
  end

  def get_flyer(event_types = nil)
    if use_course_book_cover?(event_types)
      get_book_cover(:courses, event_types)
    elsif use_seminar_book_cover?(event_types)
      get_book_cover(:seminars, event_types)
    elsif flyer.present?
      Event.buckets[:files].link(flyer&.s3_object&.key)
    end
  end

  def formatted_cost
    # html_safe: User content is restricted to integers
    return nil if cost.blank?
    return "<b>Cost:</b> $#{cost}".html_safe if member_cost.blank?
    "<b>Members:</b> $#{member_cost}, <b>Non-members:</b> $#{cost}".html_safe
  end

  def register_user(user)
    Registration.create(user: user, event: self)
  end

  def assign_instructor(user)
    EventInstructor.create(event: self, user: user)
  end

  def registerable?
    return false if expired?
    return false if cutoff?
    unless allow_member_registrations? || allow_public_registrations?
      return false
    end
    true
  end

  private

  def get_book_cover(type, event_types = nil)
    event_types ||= EventType.all
    filename = event_types.select { |e| e.id == event_type_id }.first.title
    Event.buckets[:static].link("book_covers/#{type}/#{filename}.jpg")
  end

  def use_course_book_cover?(event_types = nil)
    course?(event_types) && flyer.blank?
  end

  def use_seminar_book_cover?(event_types = nil)
    seminar?(event_types) && flyer.blank?
  end

  def validate_costs
    return unless member_cost.present?
    return if cost.present? && cost > member_cost

    self.cost = member_cost
    self.member_cost = nil
  end

  # def allow_any_registrations?
  #   allow_member_registrations? || allow_public_registrations?
  # end

  def load_event_type_ids_from_cache(event_types)
    @course_ids = event_types.find_all do |e|
      e.event_category.to_sym.in? %i[public advanced_grade elective]
    end.map(&:id)

    @seminar_ids = event_types.find_all do |e|
      e.event_category.to_sym.in? [:seminar]
    end.map(&:id)

    @meeting_ids = event_types.find_all do |e|
      e.event_category.to_sym.in? [:meeting]
    end.map(&:id)
  end
end
