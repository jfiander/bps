class Event < ApplicationRecord
  belongs_to :event_type
  has_many   :course_topics,   foreign_key: :course_id
  has_many   :course_includes, foreign_key: :course_id
  belongs_to :prereq, class_name: "EventType", optional: true

  has_many :event_instructors
  has_many :instructors, through: :event_instructors, source: :user

  before_validation do
    prefix_map_link
    validate_costs
  end

  has_attached_file :flyer,
    default_url: nil,
    storage: :s3,
    s3_region: "us-east-2",
    path: "event_flyers/:id/:filename",
    s3_permissions: :private,
    s3_credentials: aws_credentials(:files)

  validates_attachment_content_type :flyer, content_type: %r{\A(image/(jpe?g|png|gif))|(application/pdf)\z}

  scope :current, ->(category) do
    includes(:event_type, :course_topics, :course_includes, :prereq).where("expires_at > ?", Time.now).where(event_type: EventType.send(category))
  end
  scope :expired, ->(category) do
    includes(:event_type, :course_topics, :course_includes, :prereq).where("expires_at <= ?", Time.now).where(event_type: EventType.send(category))
  end

  acts_as_paranoid

  def expired?
    expires_at < Time.now
  end

  def is_a_course?
    event_type.in? EventType.courses
  end

  def is_a_seminar?
    event_type.in? EventType.seminars
  end

  def has_length?
    length.present? && length&.strftime("%-kh %Mm") != "0h 00m"
  end

  def has_multiple_sessions?
    sessions.present? && sessions > 1
  end

  def get_flyer
    key = if is_a_course? && flyer_file_name.blank?
      get_book_cover(:courses)
    elsif is_a_seminar? && flyer_file_name.blank?
      get_book_cover(:seminars)
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
    return false if cutoff_at.present? && cutoff_at < Time.now
    return false if expires_at.present? && expires_at < Time.now
    true
  end

  private

  def get_book_cover(type)
    Event.buckets[:static].link("book_covers/#{type}/#{event_type.title}.jpg")
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
