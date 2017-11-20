class User < ApplicationRecord
  devise :invitable, :registerable, :database_authenticatable, :recoverable, :trackable, :validatable, :timeoutable, :lockable
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  validates_inclusion_of :grade, in: %w( S P AP JN N SN ), message: "must be one of [S, P, AP, JN, N, SN]"

  def permitted?(role)
    role = Role.find_by(name: role.to_s)
    return false if role.blank?

    # True if user's roles include the specified role or any parent role
    role.in?(self.roles) || role.parents.any? { |r| r.in? self.roles }
  end

  def permitted_roles
    self.roles.map(&:children).flatten.map(&:name).map(&:to_sym)
  end

  def permit!(role)
    role = Role.find_by(name: role.to_s)
    UserRole.find_or_create(user: self, role: role)
  end

  def unpermit!(role)
    UserRole.where(user: self).destroy_all and return true if role == :all
    UserRole.where(user: self, role: Role.find_by(name: role.to_s)).destroy_all.present?
  end
end
