# frozen_string_literal: true

class User
  module MFA
    # Show current status, optionally generate qr code to associate
    def edit_mfa
      @enabled = current_user.mfa_enabled

      @enable = mfa_params[:enable].present?
      @disable = mfa_params[:disable].present?

      return unless @enable || @disable

      @authenticating = true
    end

    # Save changes, enable/disable mfa
    def update_mfa
      if mfa_params[:code].present?
        # Submit update to Cognito
        # Cache status to user.mfa_enabled
        # Set flash
        redirect_to profile_path
      else
        return unless authenticate!

        if mfa_params[:mfa_action] == 'enable'
          generate_svg
          render :edit_mfa
        elsif mfa_params[:mfa_action] == 'disable'
          cognito.set_mfa(current_user.certificate, false)
          current_user.update(mfa_enabled: false)
          redirect_to(profile_path, success: 'MFA has been disabled')
        end
      end
    # rescue Aws::Something
    #   flash.now[:alert] = 'There was a problem setting up MFA'
    #   redirect_to profile_path, alert: 'There was a problem setting up MFA'
    end

  private

    def mfa_params
      params.permit(:enable, :disable, :code, :mfa_action)
    end

    def user_params
      params.require(:user).permit(:current_password)
    end

    def authenticate!
      auth = cognito.authenticate(current_user.certificate, user_params[:current_password])

      # Disable auth will still challenge MFA. That should be expected, and requested along with the password on MFA removal.
      if cognito.challenged?(auth)
        if auth.challenge_name == 'SOFTWARE_TOKEN_MFA'
          current_user.update(mfa_enabled: true)
          redirect_to(profile_path, alert: 'You already have MFA enabled.')

          false
        else
          # Other challenge? How did you get here?
          false
        end
      else
        @access_token = auth.authentication_result.access_token
        @authenticating = false
        true # Allow SVG generation
      end
    rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
      flash.now[:alert] = 'Your password was incorrect.'
      @authenticating = true
      render :edit_mfa

      false
    end

    def cognito
      BPS::Cognito::Admin.new
    end

    def cognito_user
      BPS::Cognito::User.new
    end

    def generate_svg
      mfa = cognito_user.associate_mfa(@access_token)

      @svg = mfa[:svg]
      @secret = mfa[:text]
    end
  end
end
