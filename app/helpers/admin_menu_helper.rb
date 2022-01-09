# frozen_string_literal: true

module AdminMenuHelper
  def admin_menu
    @admin_menu ||= admin_menus.map do |menu, permit|
      next if permit == false
      next unless permit == true || show_link?(*permit)

      { menu => render("application/navigation/admin/#{menu}") }
    end.compact.reduce({}, :merge)
  end

  def admin_menu_groups
    {
      'Current Page' => 'sidenav-current',
      'Files' => 'sidenav-files',
      'Users' => 'sidenav-users',
      'Education' => 'sidenav-education',
      'Admin' => 'sidenav-admin'
    }
  end

  def admin_menu_sidenav(menu_id)
    menu = menu_id[8, menu_id.length]
    render("application/navigation/admin/sidenav/#{menu}", admin_links: admin_menu)
  end

  def admin_current?
    admin_markdown? || admin_events? || admin_otw? ||
      admin_event_attachments? || admin_promos? || admin_generic_payments? ||
      admin_elections?
  end

  def show_link?(*roles, strict: false, **options)
    req_cont, req_act, not_cont, not_act = link_requirements(options)
    return false unless current_user&.permitted?(roles, strict: strict)
    return false if invalid?(req_cont, req_act, not_cont, not_act)

    true
  end

private

  def link_requirements(options)
    req_cont = *options[:controller] || []
    req_action = *options[:action] || []
    not_cont = *options[:not_controller] || []
    not_action = *options[:not_action] || []

    [req_cont, req_action, not_cont, not_action]
  end

  def admin_menus
    {
      current: admin_current?, files: [:page], users_top: [:users],
      review: %i[users float roster excom], upload: %i[users roster],
      roster: %i[users roster], users_bottom: [:users], education: [:education],
      otw: [:education], completions: [:education],
      admin: [:admin, { strict: true }]
    }
  end

  def invalid?(req_cont, req_act, not_cont, not_act)
    invalid_controller?(req_cont, req_act, not_cont, not_act) ||
      invalid_action?(req_cont, req_act, not_cont, not_act) ||
      invalid_combination?(req_cont, req_act, not_cont, not_act)
  end

  def invalid_controller?(req_cont, req_act, not_cont, not_act)
    (missing_controller?(req_cont) && req_act.blank?) ||
      (wrong_controller?(not_cont) && not_act.blank?)
  end

  def invalid_action?(req_cont, req_act, not_cont, not_act)
    (missing_action?(req_act) && req_cont.blank?) || (wrong_action?(not_act) && not_cont.blank?)
  end

  def invalid_combination?(req_cont, req_act, not_cont, not_act)
    (missing_controller?(req_cont) && missing_action?(req_act)) ||
      (wrong_controller?(not_cont) && wrong_action?(not_act))
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

  def admin_promos?
    show_link?(:admin, strict: true, controller: 'promo_codes')
  end

  def admin_generic_payments?
    show_link?(:admin, strict: true, controller: 'generic_payments')
  end

  def admin_elections?
    show_link?(:admin, controller: 'elections')
  end
end
