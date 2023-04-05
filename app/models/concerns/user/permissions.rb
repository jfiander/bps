# frozen_string_literal: true

class User
  module Permissions
    extend ActiveSupport::Concern

    def permitted?(*required_roles, strict: false)
      return false if locked?

      permitted = strict ? exact_role?(*required_roles) : role?(*required_roles)
      yield if block_given? && permitted
      permitted
    end

    def permit!(role)
      return false if locked?

      return true if UserRole.exists?(user: self, role: Role.find_by(name: role.to_s))

      user_role = UserRole.create(user: self, role: Role.find_by(name: role.to_s))
      clear_cached_roles!
      user_role
    end

    def unpermit!(role)
      user_roles = UserRole.where(user: self)
      user_roles = user_roles.where(role: Role.find_by(name: role.to_s)) unless role == :all
      user_roles.destroy_all.present?
      clear_cached_roles!
    end

    def show_admin_menu?
      excom? || permitted?(%i[page users course seminar event roster float])
    end

    def granted_roles
      @granted_roles ||= roles.map { |r| r.name.to_sym }.uniq
    end

    def permitted_roles
      (granted_roles + office_roles + child_roles).map(&:to_sym).uniq
    end

    def implied_roles
      permitted_roles - granted_roles
    end

    def authorized_for_activity_feed?
      permitted?(:education, :event)
    end

    def role?(*names)
      @roles ||= {}
      @roles[names] ||= Role.recursive_lookup(*names).map(&:to_sym)
      permitted_roles.any? { |u| u.in?(@roles[names]) }
    end

    def exact_role?(*names)
      names = names.flatten.map(&:to_sym)
      @exact_role ||= {}
      @exact_role[names] ||= roles.find { |r| r.name.to_sym.in?(names) }.present?
    end

    def clear_cached_roles!
      remove_instance_variable(:@roles) if defined?(@roles)
      remove_instance_variable(:@exact_role) if defined?(@exact_role)
    end

  private

    def child_roles
      direct_roles = granted_roles + office_roles
      @child_roles ||= Role.recursive_lookdown(*direct_roles)
    end

    def office_roles
      @office_roles ||= [
        permitted_roles_from_bridge_office,
        permitted_roles_from_committee,
        (:excom if excom?)
      ].flatten.uniq.compact
    end

    def implicit_permissions
      @implicit_permissions ||= YAML.safe_load(
        Rails.root.join('config/implicit_permissions.yml').read
      )
    end

    def permitted_roles_from_bridge_office
      implicit_permissions['bridge_office'][bridge_office_name]
    end

    def permitted_roles_from_committee
      implicit_permissions['committee']&.select { |k, _| k.in?(committee_names) }&.values&.flatten
    end
  end
end
