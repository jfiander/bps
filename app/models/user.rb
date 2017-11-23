class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :trackable, :validatable, :timeoutable, :lockable
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_one  :bridge_office
  has_many :committees

  validates_inclusion_of :grade, in: %w( S P AP JN N SN ) << nil, message: "must be nil or one of [S, P, AP, JN, N, SN]"

  def full_name
    "#{first_name} #{last_name}"
  end

  def photo
    BpsS3.link(bucket: :files, key: "profile_photos/#{certificate}.png")
  end

  def permitted?(role, &block)
    role = Role.find_by(name: role.to_s)
    return false if role.blank?

    permitted = role.name.in?(permitted_roles.map(&:to_s))

    yield if permitted && block_given?
    permitted
  end

  def permitted_roles
    [
      roles.map(&:name).map(&:to_sym),
      roles.map(&:children).flatten.map(&:name).map(&:to_sym),
      permitted_roles_from_bridge_office
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
    }[bridge_office.office]
  end

  def update_invitation_limit
    self.update invitation_limit: (self.permitted?(:admin) ? nil : 0)
  end
end
