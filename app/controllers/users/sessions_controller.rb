# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
    return welcome_path if resource.sign_in_count == 1
    return referrer_params[:user][:referrer] if valid_referrer?
    members_path
  end

  private

  def valid_referrer?
    valid_pattern = %r{\A/?(?!login)(#{referrer_paths.join('|')})\z}
    return false unless referrer_params[:user][:referrer].present?
    referrer_params[:user][:referrer].match?(valid_pattern)
  rescue StandardError
    false
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
      members minutes profile permit invitation/new header file import
      user_help profile profile/edit ranks auto_permissions locations
      roster update_roster float_plan float_plans otw(/list)?
    ]
    users_paths = 'users(/\d+(/certificate(.pdf)?)?)?'
    minutes_paths = '(minutes|excom)/\d{4}/\d{1,2}'
    event_paths = '(courses|seminars|events)(/(new|(\d+(/(copy|edit))?))?)'
    edit_paths = "edit/(#{MarkdownHelper::VIEWS.map { |_, v| v }.join('|')})"

    [simple_paths, users_paths, minutes_paths, event_paths, edit_paths].flatten
  end
end
