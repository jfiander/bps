# frozen_string_literal: true

module Users
  class PasswordsController < ::Devise::PasswordsController
    # Reset instructions are emailed to whatever address is submitted, so this
    # form is an outbound mail vector for anyone who can post to it.
    prepend_before_action :verify_human!, only: :create

  private

    def verify_human!
      return if verify_recaptcha

      flash[:alert] = 'Please confirm that you are not a robot.'

      # Redirects rather than re-rendering, because prepended filters run ahead
      # of the before_action that loads the layout's images.
      redirect_to(new_user_password_path)
    end
  end
end
