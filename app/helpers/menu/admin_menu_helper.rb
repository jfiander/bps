# frozen_string_literal: true

module Menu
  module AdminMenuHelper
    def admin_menu
      content_tag(:ul, class: 'desktop') do
        safe_join(admin_menu_yaml.map do |menu, data|
          next if data[:items].none? { |d| H.display?(d) }

          admin_menu_header(menu, data)
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
      admin_menu_yaml.each do |_menu, data|
        data[:items].each do |d|
          if d.key?(:children)
            d[:children].each do |child|
              return true if H.display?(child)
            end
          elsif H.display?(d)
            return true
          end
        end
      end

      false
    end

  private

    def admin_menu_yaml
      return @admin_menu_yaml unless @admin_menu_yaml.nil?

      admin_menu_yaml = load_yaml('app/lib/admin_nav/*.yml.erb')
      propagate_defaults!(admin_menu_yaml)
      @admin_menu_yaml = admin_menu_yaml.sort_by { |_menu, data| data[:order] }
    end

    def admin_menu_header(menu, data)
      content_tag(:li, class: "menu #{menu}") do
        safe_join(
          [
            link_to(
              data[:title] || menu.to_s.titleize,
              '#',
              class: "menu-header #{menu} #{data[:button]}"
            ),
            content_tag(:ul) { safe_join(admin_menu_contents(menu, data[:items])) }
          ]
        )
      end
    end

    def admin_menu_contents(menu, data)
      data.map do |d|
        next unless H.display?(d)

        if d.key?(:children)
          next unless d[:children].any? { |c| H.display?(c) }

          if d[:text].blank?
            submenu_links(d)
          else
            content_tag(:li, class: "menu #{menu} #{d[:button]}") do
              submenu_header(menu, d) + content_tag(:ul) { submenu_links(d) }
            end
          end
        else
          menu_link(d)
        end
      end
    end

    def submenu_header(menu, data)
      link_to('#', class: "menu-header #{menu} #{data[:button]}") do
        safe_join(
          [
            FA::Icon.p(data[:icon], style: :duotone, fa: "fw #{data[:fa]}"),
            data[:text],
            content_tag(:div, FA::Icon.p('chevron-right', style: :regular, fa: :fw), class: 'arrow')
          ]
        )
      end
    end

    def submenu_links(data)
      safe_join(data[:children].map { |child| menu_link(child) })
    end

    def sidenav_content_divs
      admin_menu_yaml.map do |menu, data|
        content_tag(:div, class: 'sub-menu', id: "sidenav-#{menu}") do
          safe_join(
            [
              close_sidenav_submenu_link("sidenav-#{menu}"),
              content_tag(:h3, data[:title] || menu.to_s.titleize),
              content_tag(:ul, safe_join(sidenav_main_menu(data[:items])), class: 'simple'),
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

    def sidenav_main_menu(data)
      data.map do |d|
        next unless H.display?(d)

        if d.key?(:children)
          next unless d[:children].any? { |c| H.display?(c) }

          safe_join(
            [
              sidenav_heading(d),
              d[:children].map { |child| menu_link(child) }
            ]
          )
        else
          menu_link(d)
        end
      end
    end

    def sidenav_heading(data)
      return content_tag(:h4, 'Misc') if data[:text].blank?

      content_tag(:h4, data[:text])
    end

    def sidenav_top_buttons
      admin_menu_yaml.map do |menu, data|
        next unless H.display?(data)

        link_to('#', id: "show-sidenav-#{menu}", class: "show-sub-menu #{data[:button]}") do
          content_tag(:li, data[:title] || menu.to_s.titleize)
        end
      end
    end

    def sidenav_spacer
      content_tag(:div, '', class: 'sidenav-spacer')
    end
  end
end
