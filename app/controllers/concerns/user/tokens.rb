# frozen_string_literal: true

class User
  module Tokens
    def tokens
      unless current_user.any_current_tokens?
        redirect_to(profile_path, alert: 'You do not have any current API tokens.')
      end

      @api_tokens = current_user.api_tokens.current
      @persistent_api_tokens = current_user.persistent_api_tokens.current
    end

    def revoke_token
      klass = token_params[:persistent].present? ? PersistentApiToken : ApiToken
      klass.find(token_params[:id]).expire!
      redirect_to(profile_tokens_path, success: 'Token has been revoked.')
    end

  private

    def token_params
      params.permit(:id, :persistent)
    end
  end
end
