# frozen_string_literal: true

class UserMailerPreview < ApplicationMailerPreview
  def invitation_instructions
    UserMailer.invitation_instructions(user, 'fake-token')
  end

  def reset_password_instructions
    UserMailer.reset_password_instructions(user, 'fake-token')
  end
end
