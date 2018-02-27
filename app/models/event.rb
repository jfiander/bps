class Event < ApplicationRecord
  belongs_to :event_type
  has_many   :course_topics,   foreign_key: :course_id
  has_many   :course_includes, foreign_key: :course_id
  belongs_to :prereq, class_name: 'EventType', optional: true

  has_many :event_instructors
  has_many :instructors, through: :event_instructors, source: :user

  before_validation do
    prefix_map_link
    validate_costs
  end

  has_attached_file :flyer,
    default_url: nil,
    storage: :s3,
    s3_region: 'us-east-2',
    path: 'event_flyers/:id/:filename',
    s3_permissions: :private,
    s3_credentials: aws_credentials(:files)

  validates_attachment_content_type :flyer,
    content_type: %r{\A(image/(jpe?g|png|gif))|(application/pdf)\z}

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

  def expired?
    expires_at.present? && expires_at < Time.now
  end

  def cutoff?
    cutoff_at.present? && cutoff_at < Time.now
  end

  def category(event_types = nil)
    if event_types.present?
      course_ids = event_types.select do |e|
        e.event_category.in? [:public, :advanced_grade, :elective]
      end.map(&:id)

      seminar_ids = event_types.select do |e|
        e.event_category.in? [:seminar]
      end.map(&:id)

      meeting_ids = event_types.select do |e|
        e.event_category.in? [:meeting]
      end.map(&:id)
    else
      course_ids = EventType.courses.map(&:id)
      seminar_ids = EventType.seminars.map(&:id)
      meeting_ids = EventType.meetings.map(&:id)
    end

    return :course if event_type_id.in? course_ids
    return :seminar if event_type_id.in? seminar_ids
    return :meeting if event_type_id.in? meeting_ids
  end

  def course?(event_types = nil)
    category(event_types) == :course
  end

  def seminar?(event_types = nil)
    category(event_types) == :seminar
  end

  def meeting?(event_types = nil)
    category(event_types) == :meeting
  end

  def length?
    length.present? && length&.strftime('%-kh %Mm') != '0h 00m'
  end

  def multiple_sessions?
    sessions.present? && sessions > 1
  end

  def get_flyer(event_types = nil)
    if course?(event_types) && flyer_file_name.blank?
      get_book_cover(:courses, event_types)
    elsif seminar?(event_types) && flyer_file_name.blank?
      get_book_cover(:seminars, event_types)
    elsif flyer.present?
      Event.buckets[:files].link(flyer&.s3_object&.key)
    end
  end

  def formatted_cost
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
    return true if cutoff_at.blank? && expires_at.blank?
    return false if cutoff?
    return false if expired?
    true
  end

  private

  def get_book_cover(type, event_types = nil)
    event_types ||= EventType.all
    Event.buckets[:static].link("book_covers/#{type}/#{event_types.select { |e| e.id == event_type_id }.first.title}.jpg")
  end

  def prefix_map_link
    return if map_link.blank? || map_link.match(%r{https?://})

    self.map_link = "http://#{map_link}"
  end

  def validate_costs
    return unless member_cost.present?
    return if cost.present? && cost > member_cost

    self.cost = member_cost
    self.member_cost = nil
  end
end
