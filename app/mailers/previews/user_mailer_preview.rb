# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def invitation_instructions
    UserMailer.invitation_instructions(user, 'fake-token')
  end

  def reset_password_instructions
    UserMailer.reset_password_instructions(user, 'fake-token')
  end

private

  def user
    @user ||= User.new(email: "#{SecureRandom.hex(16)}@example.com")
  end
end
