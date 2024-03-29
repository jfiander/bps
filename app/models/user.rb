# frozen_string_literal: true

class User < ApplicationRecord
  include User::Permissions
  include User::RanksAndGrades
  include User::Lockable
  include User::Invitable
  include User::ProfilePhoto
  include User::Address
  include User::BOC
  include User::Dues
  include User::RosterFormat
  include User::Push

  devise(
    :invitable, :database_authenticatable, :recoverable, :trackable, :lockable,
    :validatable, :timeoutable
  )
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :otw_training_users, dependent: :destroy
  has_many :otw_trainings, through: :otw_training_users
  has_one  :bridge_office
  has_many :standing_committee_offices
  has_many :committees
  has_many :float_plans
  has_many :api_tokens
  has_many :persistent_api_tokens
  has_many :jobcodes

  belongs_to :parent, class_name: 'User', optional: true
  has_many :children, class_name: 'User', inverse_of: :parent, foreign_key: :parent_id

  has_many :course_completions

  has_many :member_applications, foreign_key: :approver_id, inverse_of: :approver

  has_many :event_instructors
  has_many :events, through: :event_instructors

  def self.no_photo
    ActionController::Base.helpers.image_path(BPS::S3.new(:static).link('no_profile.png'))
  end

  def self.position_associations
    %i[bridge_office standing_committee_offices committees user_roles roles]
  end

  has_attached_file(
    :profile_photo,
    paperclip_defaults(:files).merge(
      path: 'profile_photos/:id/:style/:filename', styles: { medium: '500x500', thumb: '200x200' },
      default_url: User.no_photo
    )
  )

  before_validation do
    self.rank = nil if rank.blank?
    self.first_name = ActionController::Base.helpers.sanitize(first_name)
    self.last_name = ActionController::Base.helpers.sanitize(last_name)
    self.simple_name = "#{first_name} #{last_name}"
    update_last_mm
  end

  validate :valid_rank, :valid_grade, :valid_phone_c
  validates_attachment_content_type :profile_photo, content_type: %r{\Aimage/}
  validates_attachment_file_name :profile_photo, matches: /(\.png|\.jpe?g)\z/i
  validates :certificate, uniqueness: true, allow_nil: true

  scope :locked, -> { where.not(locked_at: nil) }
  scope :unlocked, -> { where.not(id: locked) }
  scope :alphabetized, -> { order(:last_name) }
  scope :with_name, ->(name) { where(simple_name: name) }
  scope :with_any_name, -> { where.not(simple_name: [nil, '', ' ']) }
  scope :valid_instructors, -> { where('id_expr > ?', Time.zone.now) }
  scope :invitable, -> { unlocked.where('sign_in_count = 0').reject(&:placeholder_email?) }
  scope :vessel_examiners, (lambda do
    includes(:course_completions).where(course_completions: { course_key: 'VSC_01' })
  end)
  scope :include_positions, -> { includes(position_associations) }
  scope :recent_mm, -> { where('last_mm_year >= ?', Time.zone.today.beginning_of_year - 6.months) }

  def self.invitable_from(*user_ids)
    where(id: user_ids).where(invitation_sent_at: nil).invitable
  end

  # rubocop:disable Rails/OutputSafety
  # html_safe: Text is sanitized before storage
  def full_name(html: true, show_boc: false)
    sanitize(
      [
        auto_rank(html: html),
        (' ' if auto_rank.present?),
        simple_name,
        formatted_grade,
        (boc_display if show_boc)
      ].join
    ).gsub('&#39;', '’').html_safe
  end

  def bridge_hash
    # html_safe: Text is sanitized before storage
    {
      full_name: full_name.gsub(' ', '&nbsp;').html_safe,
      simple_name: simple_name.gsub(' ', '&nbsp;').html_safe,
      photo: photo
    }
  end
  # rubocop:enable Rails/OutputSafety

  def register_for(event)
    reg = Registration.not_refunded.find_or_create_by(user: self, event: event)
    mobile_phone = phone_c_preferred.present? || phone_c.present?
    add_subscription(reg) if mobile_phone && subscribe_on_register
    reg
  end

  def add_subscription(reg)
    # :nocov:
    return if reg.event.topic_arn.blank?

    subscribe_phone = phone_c_preferred.presence || phone_c
    arn = BPS::SMS.subscribe(reg.event.topic_arn, subscribe_phone).subscription_arn
    reg.update(subscription_arn: arn)
    # :nocov:
  end

  def excom?
    @excom ||= bridge_officer? || StandingCommitteeOffice.executive?(id)
  end

  def bridge_officer?
    BridgeOffice.exists?(user_id: id)
  end

  def completions
    course_completions.map(&:to_h).reduce({}, :merge)
  end

  def payment_amount
    dues
  end

  def discounted_amount
    payment_amount.to_d - Payment.discount(payment_amount)
  end

  def payable?
    # User payments are repeatable, so the default method doesn't work
    !dues.is_a?(Hash) && dues&.positive?
  end

  def valid_instructor?
    id_expr.present? && id_expr > Time.zone.now
  end

  def vessel_examiner?
    completions&.key?('VSC_01')
  end

  def cpr_aed?
    cpr_aed_expires_at.present? && cpr_aed_expires_at > Time.zone.now
  end

  def token_exists?(token)
    tokens = api_tokens.current.to_a + persistent_api_tokens.current.to_a
    tokens.find { |t| t.match?(token) }
  end

  def token_expired?(token)
    api_tokens.expired.find { |t| t.match?(token) }
  end

  def create_token(persistent: false, description: nil)
    klass = persistent ? PersistentApiToken : ApiToken
    klass.create(user: self, description: description)
  end

  def any_current_tokens?
    api_tokens.current.any? || persistent_api_tokens.current.any?
  end

private

  def cached_committees
    @cached_committees ||= committees
  end

  def committee_names
    @committee_names ||= Committee.where(user_id: id).pluck(:name)
  end

  def cached_standing_committees
    @cached_standing_committees ||= standing_committee_offices
  end

  def bridge_office_name
    bridge_office&.office
  end

  def update_last_mm
    return unless mm.to_i > mm_cache.to_i

    self.mm_cache = mm
    self.last_mm_year = Time.zone.today
  end

  def valid_phone_c
    return true if phone_c.blank?

    begin
      BPS::SMS.validate_number(phone_c)
    rescue RuntimeError => e
      raise e unless e.message =~ /^Invalid phone number to subscribe/

      errors.add(:base, 'Mobile phone must be a valid North American phone number')
    end
  end
end
