# frozen_string_literal: true

class User < ApplicationRecord
  include User::Permissions
  include User::RanksAndGrades
  include User::Lockable
  include User::Invitable
  include User::ProfilePhoto
  include User::Address

  devise(
    :invitable, :database_authenticatable, :recoverable, :trackable, :lockable,
    :validatable, :timeoutable
  )
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_one  :bridge_office
  has_many :standing_committee_offices
  has_many :committees

  has_many :course_completions

  has_many :member_applications, foreign_key: :approver_id

  has_many :event_instructors
  has_many :events, through: :event_instructors

  def self.no_photo
    ActionController::Base.helpers.image_path(
      User.buckets[:static].link('no_profile.png')
    )
  end

  has_attached_file(
    :profile_photo,
    default_url: User.no_photo,
    storage: :s3,
    s3_region: 'us-east-2',
    path: 'profile_photos/:id/:style/:filename',
    s3_permissions: :private,
    s3_credentials: aws_credentials(:files),
    styles: { medium: '500x500', thumb: '200x200' }
  )

  before_validation do
    self.rank = nil if rank.blank?
    self.first_name = ActionController::Base.helpers.sanitize(first_name)
    self.last_name = ActionController::Base.helpers.sanitize(last_name)
    self.simple_name = "#{first_name} #{last_name}"
  end

  validate :valid_rank, :valid_grade
  validates_attachment_content_type :profile_photo, content_type: %r{\Aimage/}
  validates_attachment_file_name :profile_photo, matches: /(\.png|\.jpe?g)\z/
  validates :certificate, uniqueness: true, allow_nil: true

  scope :locked,         -> { where.not(locked_at: nil) }
  scope :unlocked,       -> { where.not(id: locked) }
  scope :alphabetized,   -> { order(:last_name) }
  scope :with_name,      ->(name) { where(simple_name: name) }
  scope :with_a_name,    -> { where.not(simple_name: [nil, '', ' ']) }
  scope :with_positions, (lambda do
    includes %i[
      bridge_office standing_committee_offices committees user_roles roles
    ]
  end)
  scope :invitable, (lambda do
    unlocked.where('sign_in_count = 0').reject(&:placeholder_email?)
  end)

  def full_name(html: true)
    fn = (+'').html_safe
    fn << auto_rank(html: html)&.html_safe
    fn << ' ' if auto_rank.present?
    fn << simple_name
    fn << formatted_grade
    fn
  end

  def bridge_hash
    # html_safe: Text is sanitized before storage
    {
      full_name: full_name.gsub(' ', '&nbsp;').html_safe,
      simple_name: simple_name.gsub(' ', '&nbsp;').html_safe,
      photo: photo
    }
  end

  def register_for(event)
    Registration.create(user: self, event: event)
  end

  def request_from_store(item_id)
    ItemRequest.create(user: self, store_item_id: item_id)
  end

  def excom?
    BridgeOffice.find_by(user_id: id).present? ||
      StandingCommitteeOffice.find_by(
        committee_name: :executive, user_id: id
      ).present?
  end

  private

  def cached_committees
    @user_committees ||= committees
  end

  def cached_standing_committees
    @user_standing_committees ||= standing_committee_offices
  end

  def cached_bridge_office
    @user_bridge_office ||= bridge_office
  end
end
