# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
    return welcome_path if resource.sign_in_count == 1
    return referrer_params[:user][:referrer] if useful_referrer?
    members_path
  end

  private

  def useful_referrer?
    referrer_params[:user][:referrer].present? &&
      referrer_params[:user][:referrer] != '/login' &&
      valid_referrer?
  rescue
    false
  end

  def valid_referrer?
    member_paths = referrer_paths.join('|')
    referrer_params[:user][:referrer].match %r{\A/(#{member_paths})\z}
  end

  def referrer_params
    params.permit(user: :referrer)
  end

  def referrer_paths
    # Whitelist for valid member routes
    #
    # This whitelist is permissions-agnostic, since Devise will handle that
    # after login is complete.
    simple_paths = %w[
      members minutes users permit invitation/new header file import
      user_help profile profile/edit ranks auto_permissions locations
      roster update_roster
    ]
    profile_paths = '(users/(\d+|current))'
    minutes_paths = '((minutes|excom)/\d{4}/\d{1,2})'
    event_paths = '((courses|seminars|events)/(new|(\d+(/(copy|edit))?)))'
    edit_paths = "edit/(#{MarkdownHelper::VIEWS.map { |_, v| v }.join('|')})"
    [simple_paths, profile_paths, minutes_paths, event_paths, edit_paths]
  end
end
