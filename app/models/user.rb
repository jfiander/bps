class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :trackable, :validatable, :timeoutable, :lockable
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_one  :bridge_office
  has_many :standing_committee_offices
  has_many :committees

  def self.no_photo
    ActionController::Base.helpers.image_path(User.buckets[:static].link(key: "no_profile.png"))
  end

  has_attached_file :profile_photo,
    default_url: User.no_photo,
    storage: :s3,
    s3_region: "us-east-2",
    path: "profile_photos/:id/:filename",
    s3_permissions: :private,
    s3_credentials: {bucket: self.buckets[:files].full_bucket, access_key_id: ENV["S3_ACCESS_KEY"], secret_access_key: ENV["S3_SECRET"]}
    # styles: { medium: "300x300>", thumb: "100x100#" }

  before_validation { self.rank = nil if self.rank.blank? }

  validate :valid_rank, :valid_grade
  validates_attachment_content_type :profile_photo, content_type: /\Aimage\/jpe?g\Z/
  validates :certificate, uniqueness: true, allow_nil: true

  scope :locked,         -> { where.not(locked_at: nil) }
  scope :unlocked,       -> { where.not(id: locked) }
  scope :alphabetized,   -> { order(:last_name) }
  scope :with_positions, -> { includes(:bridge_office, :standing_committee_offices, :committees, :user_roles, :roles) }

  def simple_name
    "#{first_name} #{last_name}"
  end

  def full_name
    ranked_name = [auto_rank, "#{simple_name}"].join(" ")
    [ranked_name, grade].reject { |n| n.blank? }.join(", ")
  end

  def photo
    if profile_photo.present? && User.buckets[:files].object(key: profile_photo.s3_object.key).exists?
      User.buckets[:files].link(key: profile_photo.s3_object.key)
    else
      User.no_photo
    end
  end

  def register_for(event)
    Registration.create(user: self, event: event)
  end

  def request_from_store(item_id)
    ItemRequest.create(user: self, store_item_id: item_id)
  end

  def permitted?(*required_roles, &block)
    roles = []
    all_roles = Role.all
    required_roles.each { |role| roles << all_roles.find_by(name: role.to_s) }
    return false if roles.blank?

    permitted = false
    roles.each { |r| permitted = true if r&.name.in?(permitted_roles.map(&:to_s)) }

    yield if permitted && block_given?
    permitted
  end

  def granted_roles
    roles.map(&:name).uniq
  end

  def permitted_roles
    roles_array = roles.to_a
    all_roles = Role.all
    [
      roles_array.map(&:name).map(&:to_sym),
      roles_array.map(&:children).flatten.map(&:name).map(&:to_sym),
      permitted_roles_from_bridge_office,
      permitted_roles_from_committee
    ].flatten.uniq.reject { |r| r.nil? }
  end

  def permit!(role)
    role = Role.find_by(name: role.to_s)
    UserRole.find_or_create(user: self, role: role)
    update_invitation_limit
  end

  def unpermit!(role)
    UserRole.where(user: self).destroy_all and return true if role == :all
    UserRole.where(user: self, role: Role.find_by(name: role.to_s)).destroy_all.present?
    update_invitation_limit
  end

  def locked?
    self.locked_at.present?
  end

  def lock
    self.update(locked_at: Time.now)
  end

  def unlock
    self.update(locked_at: nil)
  end

  def self.valid_ranks
    %w[P/Lt/C P/C 1/Lt Lt/C Cdr Lt F/Lt P/D/Lt/C P/D/C D/1/Lt D/Lt/C D/C D/Lt D/Aide D/F/Lt P/Stf/C P/R/C P/V/C P/C/C N/Aide N/F/Lt P/N/F/Lt Stf/C R/C V/C C/C]
  end

  def self.valid_grades
    %w[S P AP JN N SN]
  end

  private
  def permitted_roles_from_bridge_office
    {
      "commander" => [:admin],
      "executive" => [:admin],
      "administrative" => [:users],
      "educational" => [:education],
      "secretary" => [:admin, :newsletter, :calendar, :photos, :minutes],
      "treasurer" => [:property],
      "asst_educational" => [:education],
      "asst_secretary" => [:newsletter, :calendar, :photos, :minutes]
    }[bridge_office&.office]
  end

  def permitted_roles_from_committee
    {
      "seminars" => [:seminar],
      "vsc" => [:vsc]
    }.select { |k,_| k.in? committees.map(&:search_name) }.values
  end

  def auto_rank
    bridge_rank = case bridge_office&.office
    when "commander"
      "Cdr"
    when "executive", "administrative", "educational", "secretary", "treasurer"
      "Lt/C"
    when "asst_educational", "asst_secretary"
      "1/Lt"
    end

    committee_rank = "Lt" if standing_committee_offices.present? || committees.present?
    committee_rank = "F/Lt" if "Flag Lieutenant".in? committees.map(&:name)

    bridge_rank || rank || committee_rank
  end

  def update_invitation_limit
    self.update(invitation_limit: (self.permitted?(:users) ? 1000 : 0))
  end

  def valid_rank
    return true if rank.nil?
    return true if rank.in? User.valid_ranks
    errors.add(:rank, "must be nil or in User.valid_ranks")
  end

  def valid_grade
    return true if grade.nil?
    return true if grade.in? User.valid_grades
    errors.add(:grade, "must be nil or in User.valid_grades")
  end
end
