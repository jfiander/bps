# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def invitation_instructions
    UserMailer.invitation_instructions(User.first, 'fake-token')
  end

  def reset_password_instructions
    UserMailer.reset_password_instructions(User.first, 'fake-token')
  end
end
