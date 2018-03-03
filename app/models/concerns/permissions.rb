module Permissions
  def permitted?(*required_roles, &block)
    required_roles.flatten!
    return false if required_roles.blank? || required_roles.all?(&:blank?)
    permitted = permitted_roles.any? do |p|
      p.in? required_roles.reject(&:nil?).map(&:to_sym)
    end

    yield if permitted && block_given?
    permitted
  end

  def granted_roles
    roles.map(&:name).map(&:to_sym).uniq
  end

  def permitted_roles
    [
      explicit_roles,
      implicit_roles
    ].flatten.uniq.reject(&:nil?)
  end

  def permit!(role)
    role = Role.find_by(name: role.to_s)
    UserRole.find_or_create(user: self, role: role)
  end

  def unpermit!(role)
    if role == :all
      UserRole.where(user: self).destroy_all
    else
      UserRole.where(
        user: self,
        role: Role.find_by(name: role.to_s)
      ).destroy_all.present?
    end
  end

  def show_admin_menu?
    permitted? %i[page users course seminar event]
  end

  private

  def office_roles
    [
      permitted_roles_from_bridge_office,
      permitted_roles_from_committee
    ].flatten.uniq.reject(&:nil?)
  end

  def explicit_roles
    [
      granted_roles,
      office_roles
    ].flatten.uniq.reject(&:nil?)
  end

  def implicit_roles
    all_roles ||= Role.all.to_a
    search_roles = explicit_roles

    role_objs = search_roles.map do |role|
      all_roles.find_all { |r| r.name == role.to_s }
    end.flatten

    collected_roles = []
    done = false
    until done
      new_roles = role_objs.map do |role|
        all_roles.find_all { |r| r.parent_id == role.id }
      end.flatten

      size = collected_roles.size
      collected_roles = collected_roles.push(new_roles).uniq
      done = true if collected_roles.size == size
    end

    collected_roles.flatten.map(&:name).map(&:to_sym)
  end

  def implicit_permissions
    permissions = File.read("#{Rails.root}/config/implicit_permissions.yml")
    @implicit_permissions ||= YAML.safe_load(permissions)
  end

  def permitted_roles_from_bridge_office
    implicit_permissions['bridge_office'][bridge_office&.office]&.map(&:to_sym)
  end

  def permitted_roles_from_committee
    implicit_permissions['committee']&.select do |k, _|
      k.in? committees.map(&:search_name)
    end&.values&.flatten&.map(&:to_sym)
  end
end
