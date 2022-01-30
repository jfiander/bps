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

      UserRole.find_or_create_by(
        user: self,
        role: Role.find_by(name: role.to_s)
      )
    end

    def unpermit!(role)
      user_roles = UserRole.where(user: self)
      user_roles = user_roles.where(role: Role.find_by(name: role.to_s)) unless role == :all
      user_roles.destroy_all.present?
    end

    def show_admin_menu?
      excom? || permitted?(%i[page users course seminar event roster float])
    end

    def granted_roles
      @granted_roles ||= roles.pluck(:name).map(&:to_sym).uniq
    end

    def permitted_roles
      (granted_roles + office_roles + child_roles).map(&:to_sym).uniq
    end

    def authorized_for_activity_feed?
      permitted?(:education, :event)
    end

    def role?(*names)
      check_roles = Role.recursive_lookup(*names).map(&:to_sym)
      permitted_roles.any? { |u| u.in?(check_roles) }
    end

    def exact_role?(*names)
      user_roles.joins(:role).where(roles: { name: names }).exists?
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
        File.read("#{Rails.root}/config/implicit_permissions.yml")
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
