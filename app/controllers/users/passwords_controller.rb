# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end
  #
  # This should be fine, since it's just the form to request a token be emailed

  # POST /resource/password
  def create
    cognito.forgot_password(find_username_by_username_or_email)
  rescue Aws::CognitoIdentityProvider::Errors::UserNotFoundException
    # User actually does not exist in Cognito. Reroute to legacy system.
    super
  end
  #
  # FOLLOWUP: What does this email actually look like? Does it redirect to a custom URL? or is it in the hosted UI?

  # PUT /resource/password
  def update
    # Only proceed if password and password_confirm match
    raise PasswordMismatchError unless params[:user][:password] == params[:user][:password_confirmation]

    # Check if the user exists in Cognito, before attempting to update the password there.
    admin.get_user(username)

    # Submit request including token to Cognito
    cognito.confirm_forgot_password(username, params[:user_code], params[:user][:password])
  rescue PasswordMismatchError
    # Allow Devise to take over from here.
    super
  rescue ArgumentError => e
    raise e unless e.message =~ /^parameter validator found /
    # Cognito rejected the password update request.
  rescue Aws::CognitoIdentityProvider::Errors::CodeMismatchException
    # Reset token was wrong.

    # Handle failed? Does Devise have a method to do this? Just a flash and redirect to root? Dedicated page?
  rescue Aws::CognitoIdentityProvider::Errors::UserNotFoundException
    # User actually does not exist in Cognito. Reroute to legacy system.
    super
  end

private

  def admin
    BPS::Cognito::Admin.new
  end

  def cognito
    BPS::Cognito::User.new
  end

  def find_username_by_username_or_email
    input = params[:user][:username] || params[:user][:email]
    admin.get_user(input)
    input
  rescue Aws::CognitoIdentityProvider::Errors::UserNotFoundException => e
    user = admin.get_user_by_email(input)
    user ? user.username : raise(e)
  end

  class PasswordMismatchError < StandardError; end
end
