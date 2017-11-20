module NavigationHelper
  def menu(title = nil, permit: nil, links: {}, show_when: :always)
    return nil unless show_menu?(title: title, permit: permit, show_when: show_when, links: links)

    html_output = if title == :login_or_logout
      content_tag(:li) do
        user_signed_in? ? link_to("Logout", destroy_user_session_path, {method: :delete, class: "red"}) : link_to("Member Login", new_user_session_path)
      end
    else
      generate_regular_menu(title, permit: permit, links: links)
    end

    html_output.to_s.html_safe
  end

  def link(title = nil, permit: nil, path: nil, show_when: :always)
    # This aliases a simple link for easier readability in the view
    menu(title, permit: permit, links: {title.to_s.titleize => path}, show_when: show_when)
  end

  private
  def show_menu?(title: nil, permit:, show_when:, links:)
    show_when == :always ||                                         # Menu set to always show
    title.in?([:home, :login_or_logout]) ||                         # Specific menus that always show
    !hide_menu?(permit: permit, show_when: show_when, links: links) # Menu is not valid for the current situation
  end

  def hide_menu?(permit:, show_when:, links:)
    links.blank? ||                                        # Do not show empty menus
    (show_when == :logged_in && !user_signed_in?) ||       # Requires logged in user
    (show_when == :logged_out && user_signed_in?) ||       # Requires logged out user
    (permit.present? && !current_user&.permitted?(permit)) # Current user does not have access
  end

  def generate_regular_menu(title = nil, permit: nil, links: nil)
    # This nesting allows for several options:
    # 1) Simple links
    # 2) One-level menus of entirely simple links
    # 3) Two-level menus of simple links and one-level sub-menus of simple links

    content_tag(:li, class: "menu", onclick: "") do

      output = if links.count == 1
        # Single top level link
        single_link(name: links.keys.first, link: links.values.first, permit: permit)
      else
        generate_top_menu()
      end

      output.to_s.html_safe
    end
  end

  def generate_top_menu(title = nil, permit: nil, links: nil)
    # Top level menu
    main_menu = ""

    main_menu << content_tag(:a, class: permit) { title_with_arroes(title) }

    main_menu << content_tag(:ul) { sub_menu(links: links, permit: permit) }

    main_menu.html_safe
  end

  def title_with_arroes(title)
    (content_tag(:div, "▸", class: "right-arrow") + content_tag(:div, "▾", class: "down-arrow") + title.to_s.titleize).html_safe
  end

  def sub_menu(links:, permit: nil)
    sub_menu = ""
    links.each do |sub_name, sub_links|
      next if sub_links.blank? # Skip blank sub-menus
      sub_menu << single_link(name: sub_name, link: sub_links, permit: permit) and next if sub_links.is_a?(String) # Single sub link
      sub_menu << content_tag(:li, class: "menu", onclick: "") { sub_sub_menu(name: sub_name, links: sub_links) } # Sub menu
    end
    sub_menu.html_safe
  end

  def single_link(name:, link:, permit: nil)
    content_tag(:li, link_to(name, link, {class: permit.to_s}), class: permit.to_s).html_safe
  end

  def sub_sub_menu(name:, links:)
    menu = ""
    menu << content_tag(:a, (name + content_tag(:div, "▸", class: "nested-right-arrow")).html_safe, class: permit)
    menu << content_tag(:ul) do
      links.map { |link_name, link_path| single_link(name: link_name, link: link_path, permit: permit) }.join.html_safe
    end
    menu.html_safe
  end
end
