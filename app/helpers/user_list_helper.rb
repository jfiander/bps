# frozen_string_literal: true

module UserListHelper
  def user_actions(user)
    return content_tag(:div, class: 'actions') { unlock_link(user[:id]) } if user[:locked]

    content_tag(:div, class: 'actions') do
      profile_links(user[:id])
      invitation_link(user)
      lockable_link(user)
    end
  end

private

  def profile_links(user_id)
    concat profile_link(user_id)
    concat certificate_link(user_id)
    concat boc_progress_link(user_id)
  end

  def invitation_link(user)
    if user[:invited]
      concat reinvite_link(user[:id])
    elsif user[:invitable]
      concat invite_link(user[:id])
    elsif user[:placeholder_email]
      concat no_email
    else
      concat logged_in
    end
  end

  def lockable_link(user)
    if !user[:permitted_roles].include?(:admin)
      concat lock_link(user[:id])
    elsif user[:permitted_roles].include?(:admin)
      concat cannot_lock_admin
    end
  end

  def profile_link(user_id)
    user_list_link(user_path(user_id), nil, nil, 'user', 'Profile')
  end

  def certificate_link(user_id)
    user_list_link(
      user_certificate_path(user_id), nil, nil, 'file-certificate', 'Educational certificate'
    )
  end

  def boc_progress_link(user_id)
    user_list_link(otw_progress_path(user_id), nil, nil, 'tasks', 'BOC progress')
  end

  def reinvite_link(user_id)
    user_list_link(invite_path(user_id), nil, :put, 'envelope-open', 'Re-send invitation')
  end

  def invite_link(user_id)
    user_list_link(invite_path(user_id), nil, :put, 'envelope', 'Send invitation')
  end

  def lock_link(user_id)
    user_list_link(lock_user_path(user_id), 'lock', :patch, 'unlock', 'Lock')
  end

  def unlock_link(user_id)
    user_list_link(unlock_user_path(user_id), 'unlock', :patch, 'lock', 'Unlock')
  end

  def no_email
    disabled_icon('envelope', :gray, 'exclamation', :red, 'Invalid email address')
  end

  def logged_in
    disabled_icon('envelope', :gray, 'check', :green, 'Logged in successfully')
  end

  def cannot_lock_admin
    disabled_icon('unlock', :gray, 'ban', :red, 'Cannot lock admins')
  end

  def user_list_link(path, css, method, icon, title)
    link_to(path, class: css, method: method) do
      FA::Icon.p(icon, style: :duotone, fa: :fw, title: title)
    end
  end

  def disabled_icon(base, base_css, top, top_css, title)
    FA::Layer.p(
      [
        { name: base, options: { css: base_css } },
        { name: top, options: { css: top_css } }
      ], title: title
    )
  end
end
