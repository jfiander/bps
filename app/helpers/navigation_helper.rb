module NavigationHelper
  def link(title = nil, permit: nil, path: nil, show_when: :always, suffix: "", active: false, icon: nil)
    return nil unless show_menu?(title: title, permit: permit, show_when: show_when, path: path)

    options = {class: permit.to_s}

    if title == :login_or_logout && user_signed_in?
      title = "Logout"
      path = destroy_user_session_path
      options = {method: :delete, class: "red"}
      icon = "sign-out"
    elsif title == :login_or_logout
      title = "Member Login"
      path = new_user_session_path
      options = {class: "members"}
      icon = "sign-in"
    elsif title.in? [:members_area, :profile, :admin]
      options = {class: "members"}
    elsif title == "Edit This Page"
      options = {"data-turbolinks" => "false"}
    end

    title = title.to_s.titleize if title.is_a?(Symbol)
    css_class = permit.to_s
    css_class += " active" if active

    icon_tag = icon.present? ? fa_icon(icon) : ""
    link = link_to(path, options) do
      content_tag(:li, class: css_class) do
        icon_tag + title
      end
    end

    link.html_safe + suffix
  end

  private
  def show_menu?(title: nil, permit:, show_when:, path:)
    show_when == :always ||                                       # Menu set to always show
    title.in?([:home, :login_or_logout]) ||                       # Specific menus that always show
    !hide_menu?(permit: permit, show_when: show_when, path: path) # Menu is not valid for the current situation
  end

  def hide_menu?(permit:, show_when:, path:)
    path.blank? ||                                         # Do not show empty menus
    (show_when == :logged_in && !user_signed_in?) ||       # Requires logged in user
    (show_when == :logged_out && user_signed_in?) ||       # Requires logged out user
    (permit.present? && !current_user&.permitted?(permit)) # Current user does not have access
  end
end
