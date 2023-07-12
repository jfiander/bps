# frozen_string_literal: true

module AdminMenuHelper
  include Rails.application.routes.url_helpers

  def admin_menu
    content_tag(:ul, class: 'desktop') do
      safe_join(combined_yaml.map do |menu, data|
        next if data[:items].none? { |d| d[:display] }

        content_tag(:li, class: "menu #{menu}") do
          safe_join(
            [
              link_to(data[:title] || menu.to_s.titleize, '#', class: "menu-header #{menu}"),
              content_tag(:ul) { safe_join(admin_menu_contents(menu, data[:items])) }
            ]
          )
        end
      end)
    end
  end

  def sidenav_admin_menu
    return unless any_admin_links?

    safe_join(
      [
        content_tag(:h3, 'Admin'),
        sidenav_content_divs,
        content_tag(:ul, safe_join(sidenav_top_buttons), class: 'simple'),
        sidenav_spacer
      ]
    )
  end

  def any_admin_links?
    combined_yaml.each do |_menu, data|
      data[:items].each do |d|
        if d.key?(:children)
          d[:children].each do |child|
            return true if child[:display]
          end
        elsif d[:display]
          return true
        end
      end
    end

    false
  end

  def show_link?(*roles, strict: false, **options)
    req_cont, req_act, not_cont, not_act = H.link_requirements(options)
    return false unless current_user&.permitted?(roles, strict: strict)
    return false if H.invalid?(req_cont, req_act, not_cont, not_act, controller)

    true
  end

private

  def combined_yaml
    return @combined_yaml unless @combined_yaml.nil?

    yaml_files = Rails.root.glob('app/lib/admin_nav/*.yml.erb')
    combined_yaml = yaml_files.each_with_object({}) do |path, hash|
      yaml = YAML.safe_load(ERB.new(File.read(path)).result(binding))
      hash.merge!(yaml)
    end.deep_symbolize_keys!

    @combined_yaml = combined_yaml.sort_by { |_menu, data| data[:order] }
  end

  def admin_menu_contents(menu, data)
    data.map do |d|
      next if d.key?(:display) && !d[:display]

      if d.key?(:children)
        next unless d[:children].any? { |c| c[:display] }

        if d[:text].blank?
          submenu_links(menu, d)
        else
          content_tag(:li, class: "menu #{menu}") do
            submenu_header(menu, d) + content_tag(:ul) { submenu_links(menu, d) }
          end
        end
      else
        admin_menu_link(d)
      end
    end
  end

  def admin_menu_link(data)
    link(
      data[:text],
      path: data[:path],
      admin: data[:button] == 'admin',
      fa: { name: data[:icon], options: { style: :duotone, fa: "fw #{data[:fa]}" } }
    )
  end

  def submenu_header(menu, data)
    link_to('#', class: "menu-header #{menu}") do
      safe_join(
        [
          FA::Icon.p(data[:icon], style: :duotone, fa: "fw #{data[:fa]}"),
          data[:text],
          content_tag(:div, FA::Icon.p('chevron-right', style: :regular, fa: :fw), class: 'arrow')
        ]
      )
    end
  end

  def submenu_links(menu, data)
    safe_join(data[:children].map { |child| admin_menu_link(child) })
  end

  def sidenav_content_divs
    combined_yaml.map do |menu, data|
      content_tag(:div, class: 'sub-menu', id: "sidenav-#{menu}") do
        safe_join(
          [
            close_sidenav_submenu_link("sidenav-#{menu}"),
            content_tag(:h3, data[:title] || menu.to_s.titleize),
            content_tag(:ul, safe_join(sidenav_main_menu(menu, data[:items])), class: 'simple'),
            sidenav_spacer
          ]
        )
      end
    end
  end

  def close_sidenav_submenu_link(menu_id)
    link_to('#', id: "hide-#{menu_id}", class: 'red close-sidenav') do
      safe_join([FA::Icon.p('times-square', style: :duotone), 'Close'])
    end
  end

  def sidenav_main_menu(menu, data)
    data.map do |d|
      next if d.key?(:display) && !d[:display]

      if d.key?(:children)
        next unless d[:children].any? { |c| c[:display] }

        safe_join(
          [
            sidenav_heading(d),
            d[:children].map { |child| admin_menu_link(child) }
          ]
        )
      else
        admin_menu_link(d)
      end
    end
  end

  def sidenav_heading(data)
    return content_tag(:h4, 'Misc') if data[:text].blank?

    content_tag(:h4, data[:text])
  end

  def sidenav_top_buttons
    combined_yaml.map do |menu, data|
      link_to('#', id: "show-sidenav-#{menu}", class: "show-sub-menu #{data[:button]}") do
        content_tag(:li, data[:title] || menu.to_s.titleize)
      end
    end
  end

  def sidenav_spacer
    content_tag(:div, '', class: 'sidenav-spacer')
  end

  # Internal helper methods
  module H
    class << self
      def link_requirements(options)
        req_cont = *options[:controller] || []
        req_action = *options[:action] || []
        not_cont = *options[:not_controller] || []
        not_action = *options[:not_action] || []

        [req_cont, req_action, not_cont, not_action]
      end

      def invalid?(req_cont, req_act, not_cont, not_act, controller)
        @controller = controller

        invalid_controller?(req_cont, req_act, not_cont, not_act) ||
          invalid_action?(req_cont, req_act, not_cont, not_act) ||
          invalid_combination?(req_cont, req_act, not_cont, not_act)
      end

    private

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

        !@controller.controller_name.in?(req_controller)
      end

      def wrong_controller?(not_controller = nil)
        return false if not_controller.blank?

        @controller.controller_name.in?(not_controller)
      end

      def missing_action?(req_action = nil)
        return false if req_action.blank?

        !@controller.action_name.in?(req_action)
      end

      def wrong_action?(not_action = nil)
        return false if not_action.blank?

        @controller.action_name.in?(not_action)
      end
    end
  end
end
