# frozen_string_literal: true

module User::Permissions
  SIMPLIFY = proc { |roles| roles.flatten.uniq.compact }

  class << self
    def reload_implicit_roles_hash
      @implicit_roles_hash = Role.includes(:children).map do |role|
        { role.name.to_sym => role.children.map { |r| r.name.to_sym } }
      end.reduce({}, :merge).freeze
    end

    def implicit_roles_hash
      @implicit_roles_hash ||= reload_implicit_roles_hash
    end
  end

  def permitted?(*required_roles, strict: false, session: nil)
    return false if locked?
    required = SIMPLIFY.call(required_roles)
    return false if required.blank? || required.all?(&:blank?)

    permitted = searchable_roles(strict, session: session).any? do |p|
      p.in?(required.map(&:to_sym))
    end

    yield if block_given? && permitted
    permitted
  end

  def permit!(role)
    return false if locked?

    UserRole.find_or_create_by(
      user: self,
      role: Role.find_by(name: role.to_s)
    )
  end

  def unpermit!(role)
    user_roles = UserRole.where(user: self)
    unless role == :all
      user_roles = user_roles.where(role: Role.find_by(name: role.to_s))
    end
    user_roles.destroy_all.present?
  end

  def show_admin_menu?
    excom? || permitted?(%i[page users course seminar event roster float])
  end

  def granted_roles
    roles.map(&:name).map(&:to_sym).uniq
  end

  def permitted_roles
    SIMPLIFY.call([explicit_roles, implicit_roles])
  end

  private

  def searchable_roles(strict = false, session: nil)
    return session_roles(strict, session) if session.present?

    lookup_roles(strict)
  end

  def session_roles(strict, session)
    strict ? session[:granted] : session[:permitted]
  end

  def lookup_roles(strict)
    strict ? granted_roles : permitted_roles
  end

  def office_roles
    SIMPLIFY.call(
      [
        permitted_roles_from_bridge_office,
        permitted_roles_from_committee,
        (:excom if excom?)
      ]
    )
  end

  def explicit_roles
    SIMPLIFY.call([granted_roles, office_roles])
  end

  def implicit_roles
    i_roles = []
    new_roles = child_roles(explicit_roles)

    while (new_roles - i_roles).present?
      i_roles << new_roles
      i_roles.flatten!
      new_roles = child_roles(i_roles)
    end
    i_roles << new_roles

    SIMPLIFY.call(i_roles)
  end

  def child_roles(parent_roles)
    SIMPLIFY.call(
      parent_roles.map { |role| User::Permissions.implicit_roles_hash[role] }
    )
  end

  def implicit_permissions
    @implicit_permissions ||= YAML.safe_load(
      File.read("#{Rails.root}/config/implicit_permissions.yml")
    )
  end

  def permitted_roles_from_bridge_office
    implicit_permissions['bridge_office'][cached_bridge_office&.office]
      &.map(&:to_sym)
  end

  def permitted_roles_from_committee
    implicit_permissions['committee']&.select do |k, _|
      k.in? cached_committees.map(&:name)
    end&.values&.flatten&.map(&:to_sym)
  end
end
