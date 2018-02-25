# Preview all emails at http://localhost:3000/rails/mailers/registration_mailer
class RegistrationMailerPreview < ActionMailer::Preview
  def registered
    RegistrationMailer.registered(registration)
  end

  def cancelled
    RegistrationMailer.cancelled(registration)
  end

  def public
    RegistrationMailer.public(registration)
  end

  private

  def registration
    Registration.last
  end
end
