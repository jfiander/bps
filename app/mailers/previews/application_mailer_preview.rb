# frozen_string_literal: true

class ApplicationMailerPreview < ActionMailer::Preview
  # This class defines no public methods.
  def _; end

private

  def user
    @user = User.new(
      certificate: 'E987654', parent_id: nil, first_name: 'Jack', last_name: 'Member', email: email
    )
    @user.simple_name = 'Jack Member'
    @user.id = -999
    @user
  end

  def email
    "#{SecureRandom.hex(16)}@example.com"
  end
end
