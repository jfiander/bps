class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :trackable, :validatable, :timeoutable, :lockable
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_one  :bridge_office
  has_many :standing_committee_office
  has_many :committees, foreign_key: :chair_id

  def self.no_photo
    ActionController::Base.helpers.image_path("no_profile.png")
  end

  has_attached_file :profile_photo,
    default_url: User.no_photo,
    storage: :s3,
    s3_region: "us-east-2",
    path: "#{Rails.env}/profile_photos/:id/:filename",
    s3_permissions: :private,
    s3_credentials: {bucket: "bps-files", access_key_id: ENV["S3_ACCESS_KEY"], secret_access_key: ENV["S3_SECRET"]}
    # styles: { medium: "300x300>", thumb: "100x100#" }

  validates_inclusion_of :grade, in: %w( S P AP JN N SN ) << nil, message: "must be nil or one of [S, P, AP, JN, N, SN]"
  validates_attachment_content_type :profile_photo, content_type: /\Aimage\/jpe?g\Z/

  def full_name
    [
      [(auto_rank || rank), "#{first_name} #{last_name}"].join(" "),
      grade
    ].reject { |n| n.blank? }.join(", ")
  end

  def photo
    if profile_photo.present? && BpsS3.get_object(bucket: :files, key: profile_photo.s3_object.key).exists?
      profile_photo.s3_object.presigned_url(:get, expires_in: 15.seconds)
    else
      User.no_photo
    end
  end

  def register_for(event)
    Registration.create(user: self, event: event)
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

  def permitted_roles
    roles_array = roles.to_a
    all_roles = Role.all
    [
      roles_array.map(&:name).map(&:to_sym),
      all_roles.find_all { |r| r.parent_id.in?(roles_array.map(&:id)) }.map(&:name).map(&:to_sym),
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

  private
  def permitted_roles_from_bridge_office
    {
      "commander" => [:admin],
      "executive" => [:admin],
      "administrative" => [:users],
      "educational" => [:education],
      "secretary" => [:admin, :newsletter],
      "treasurer" => [:property],
      "asst_educational" => [:education],
      "asst_secretary" => [:newsletter]
    }[bridge_office&.office]
  end

  def permitted_roles_from_committee
    {
      "seminars" => [:seminar],
      "vsc" => [:vsc]
    }.select { |k,_| k.in? committees.map(&:name) }.values
  end

  def auto_rank
    case bridge_office&.office
    when "commander"
      "Cdr"
    when "executive", "administrative", "educational", "secretary", "treasurer"
      "Lt/C"
    when "asst_educational", "asst_secretary"
      "1/Lt"
    end
  end

  def update_invitation_limit
    self.update invitation_limit: (self.permitted?(:admin) ? nil : 0)
  end
end
