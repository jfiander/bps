# frozen_string_literal: true

module AdminMenuHelper
  def admin_menu
    @admin_menu ||= admin_menus.map do |menu, permit|
      next if permit == false
      next unless permit == true || show_link?(*permit)

      { menu => render("application/navigation/admin/#{menu}") }
    end.compact.reduce({}, :merge)
  end

  def admin_current?
    admin_markdown? || admin_events? || admin_otw? || admin_event_attachments?
  end

  def show_link?(*roles, strict: false, **options)
    req_cont = *options[:controller] || []
    req_action = *options[:action] || []
    not_cont = *options[:not_controller] || []
    not_action = *options[:not_action] || []

    return false unless current_user&.permitted?(roles, strict: strict, session: session)
    return false if invalid?(req_cont, req_action, not_cont, not_action)
    true
  end

private

  def admin_menus
    {
      current: admin_current?, files: [:page], users_top: [:users],
      review: %i[users float roster excom], upload: %i[users roster],
      roster: %i[users roster], users_bottom: [:users], education: [:education],
      otw: [:education], completions: [:education],
      admin: [:admin, { strict: true }]
    }
  end

  def invalid?(rc, ra, nc, na)
    invalid_controller?(rc, ra, nc, na) ||
      invalid_action?(rc, ra, nc, na) ||
      invalid_combination?(rc, ra, nc, na)
  end

  def invalid_controller?(rc, ra, nc, na)
    (missing_controller?(rc) && ra.blank?) ||
      (wrong_controller?(nc) && na.blank?)
  end

  def invalid_action?(rc, ra, nc, na)
    (missing_action?(ra) && rc.blank?) ||
      (wrong_action?(na) && nc.blank?)
  end

  def invalid_combination?(rc, ra, nc, na)
    (missing_controller?(rc) && missing_action?(ra)) ||
      (wrong_controller?(nc) && wrong_action?(na))
  end

  def missing_controller?(req_controller = nil)
    return false unless req_controller.present?
    !controller_name.in?(req_controller)
  end

  def wrong_controller?(not_controller = nil)
    return false unless not_controller.present?
    controller_name.in?(not_controller)
  end

  def missing_action?(req_action = nil)
    return false unless req_action.present?
    !controller.action_name.in?(req_action)
  end

  def wrong_action?(not_action = nil)
    return false unless not_action.present?
    controller.action_name.in?(not_action)
  end

  def admin_markdown?
    show_link?(:page, action: StaticPage.names)
  end

  def admin_events?
    show_link?(event_type_param, controller: %w[courses seminars events])
  end

  def admin_otw?
    show_link?(:otw, controller: %w[otw_trainings])
  end

  def admin_event_attachments?
    show_link?(%i[event seminar course], controller: %w[event_types locations])
  end
end
