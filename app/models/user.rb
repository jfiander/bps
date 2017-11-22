class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :trackable, :validatable, :timeoutable, :lockable
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_one  :bridge_office
  has_many :committees

  validates_inclusion_of :grade, in: %w( S P AP JN N SN ) << nil, message: "must be one of [S, P, AP, JN, N, SN]"

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def photo
    BpsS3.link(bucket: :files, key: "profile_photos/#{self.certificate}.png")
  end

  def permitted?(role, &block)
    role = Role.find_by(name: role.to_s)
    return false if role.blank?

    # True if user's roles include the specified role or any parent role
    permitted = role.in?(self.roles) || role.parents.any? { |r| r.in? self.roles }

    yield and return if block_given?
    permitted
  end

  def permitted_roles
    self.roles.map(&:children).flatten.map(&:name).map(&:to_sym)
  end

  def permit!(role)
    role = Role.find_by(name: role.to_s)
    UserRole.find_or_create(user: self, role: role)
    self.update(invitation_limit: nil) if role == Role.find_by(name: "admin")
  end

  def unpermit!(role)
    UserRole.where(user: self).destroy_all and return true if role == :all
    UserRole.where(user: self, role: Role.find_by(name: role.to_s)).destroy_all.present?
    self.update(invitation_limit: 0) if role == Role.find_by(name: "admin")
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
end
