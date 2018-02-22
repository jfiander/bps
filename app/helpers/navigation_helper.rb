module NavigationHelper
  def link(title = nil, permit: nil, path: nil, show_when: :always, suffix: '', active: false, fa: nil, css_class: '')
    return nil unless show_menu?(title: title, permit: permit, show_when: show_when, path: path)

    options = {class: permit.to_s}

    if title == :login_or_logout && user_signed_in?
      title = 'Logout'
      path = destroy_user_session_path
      options = { method: :delete, class: 'red' }
      fa = { name: 'sign-out', options: { style: :regular } }
    elsif title == :login_or_logout
      title = 'Member Login'
      path = new_user_session_path
      options = { class: 'members' }
      fa = { name: 'sign-in', options: { style: :regular } }
    elsif title.in? [:members_area, :profile, :admin]
      options = { class: 'members' }
    end

    title = title.to_s.titleize if title.is_a?(Symbol)
    classes = [css_class]
    classes << permit if permit
    classes << 'active' if active
    css_class = classes.join(' ')

    icon_tag = fa.present? ? fa_icon(fa) : ''
    link = link_to(path, options) do
      content_tag(:li, class: css_class) do
        icon_tag + title
      end
    end

    link.html_safe + suffix
  end

  private
  def show_menu?(title: nil, permit:, show_when:, path:)
    show_when == :always ||                                         # Menu set to always show
      title.in?([:home, :login_or_logout]) ||                       # Specific menus that always show
      !hide_menu?(permit: permit, show_when: show_when, path: path) # Menu is not valid for the current situation
  end

  def hide_menu?(permit:, show_when:, path:)
    path.blank? ||                                           # Do not show empty menus
      (show_when == :logged_in && !user_signed_in?) ||       # Requires logged in user
      (show_when == :logged_out && user_signed_in?) ||       # Requires logged out user
      (permit.present? && !current_user&.permitted?(permit)) # Current user does not have access
  end
end
