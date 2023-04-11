# frozen_string_literal: true

module AdminMenuHelper
  def sidenav_admin_menu
    return unless current_user&.show_admin_menu? && admin_menu.values.any?

    buttons = []
    submenus = []

    admin_menu_groups.map do |heading, id|
      menu_id = "sidenav-#{id}"
      buttons << show_sidenav_submenu_link(heading, menu_id)
      submenus << sidenav_admin_submenu(heading, menu_id)
    end

    sidenav_construct_menu(buttons, submenus)
  end

  def sidenav_construct_menu(buttons, submenus)
    content_tag(:h3, 'Admin') +
      safe_join(submenus) +
      content_tag(:ul, safe_join(buttons), class: 'simple') +
      content_tag(:div, nil, class: 'sidenav-spacer')
  end

  def sidenav_admin_submenu(heading, menu_id)
    content_tag(:div, class: 'sub-menu', id: menu_id) do
      close_sidenav_submenu_link(menu_id) +
        content_tag(:h3, heading) +
        content_tag(:ul, admin_menu_sidenav(menu_id), class: 'simple') +
        content_tag(:div, nil, class: 'sidenav-spacer')
    end
  end

  def show_sidenav_submenu_link(heading, menu_id)
    button_class = { 'Admin' => 'admin', 'Current Page' => '' }[heading] || 'members'

    link_to('#', id: "show-#{menu_id}", class: "show-sub-menu #{button_class}") do
      content_tag(:li, heading)
    end
  end

  def close_sidenav_submenu_link(menu_id)
    link_to('#', id: "hide-#{menu_id}", class: 'red close-sidenav') do
      safe_join([FA::Icon.p('times-square', style: :duotone), 'Close'])
    end
  end

  def admin_menu
    @admin_menu ||= admin_menus.each_with_object({}) do |(menu, permit), hash|
      next if permit == false
      next unless permit == true || show_link?(*permit)

      hash[menu] = render("application/navigation/admin/#{menu}")
    end
  end

  def admin_menu_groups
    @admin_menu_groups ||= {}.tap do |h|
      h['Current Page'] = 'current' if admin_current?
      h['Files'] = 'files' if show_link?(:page)
      h['Users'] = 'users' if show_link?(:users, :float, :roster, :excom)
      h['Education'] = 'education' if show_link?(:otw, :education)
      h['Admin'] = 'admin' if show_link?(:admin, strict: true)
    end
  end

  def admin_menu_sidenav(menu_id)
    menu = menu_id[8, menu_id.length]
    render("application/navigation/admin/sidenav/#{menu}", admin_links: admin_menu)
  end

  def admin_current?
    admin_markdown? || admin_events? || admin_otw? ||
      admin_event_attachments? || admin_promos? || admin_generic_payments?
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
      roster: %i[users roster], lists: %i[users], users_bottom: [:users],
      education: [:education], otw: [:education], completions: [:education],
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
    return false if req_controller.blank?

    !controller_name.in?(req_controller)
  end

  def wrong_controller?(not_controller = nil)
    return false if not_controller.blank?

    controller_name.in?(not_controller)
  end

  def missing_action?(req_action = nil)
    return false if req_action.blank?

    !controller.action_name.in?(req_action)
  end

  def wrong_action?(not_action = nil)
    return false if not_action.blank?

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
end
