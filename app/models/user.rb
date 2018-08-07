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

  belongs_to :parent, class_name: 'User', optional: true
  has_many(
    :children,
    class_name: 'User',
    inverse_of: :parent,
    foreign_key: :parent_id
  )

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
    paperclip_defaults(:files).merge(
      path: 'profile_photos/:id/:style/:filename',
      styles: { medium: '500x500', thumb: '200x200' },
      default_url: User.no_photo
    )
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

  scope :locked,            -> { where.not(locked_at: nil) }
  scope :unlocked,          -> { where.not(id: locked) }
  scope :alphabetized,      -> { order(:last_name) }
  scope :with_name,         ->(name) { where(simple_name: name) }
  scope :with_any_name,     -> { where.not(simple_name: [nil, '', ' ']) }
  scope :valid_instructors, -> { where('id_expr > ?', Time.now) }

  def self.include_positions
    includes %i[
      bridge_office standing_committee_offices committees user_roles roles
    ]
  end

  def self.invitable
    unlocked.where('sign_in_count = 0').reject(&:placeholder_email?)
  end

  def full_name(html: true, show_boc: false)
    # html_safe: No user content
    fn = (+'').html_safe
    fn << auto_rank(html: html)&.html_safe
    fn << ' ' if auto_rank.present?
    fn << simple_name
    fn << formatted_grade
    fn << boc_display if show_boc
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

  def excom?
    BridgeOffice.find_by(user_id: id).present? ||
      StandingCommitteeOffice.find_by(
        committee_name: :executive, user_id: id
      ).present?
  end

  def completions
    course_completions.map(&:to_h).reduce({}, :merge)
  end

  def payment_amount
    dues
  end

  private

  def cached_committees
    @cached_committees ||= committees
  end

  def cached_standing_committees
    @cached_standing_committees ||= standing_committee_offices
  end

  def cached_bridge_office
    @cached_bridge_office ||= bridge_office
  end
end
