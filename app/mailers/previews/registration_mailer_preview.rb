# Preview all emails at http://localhost:3000/rails/mailers/registration_mailer
class RegistrationMailerPreview < ActionMailer::Preview
  def registered
    RegistrationMailer.registered(registration)
  end

  def cancelled
    RegistrationMailer.cancelled(registration)
  end

  def confirm
    RegistrationMailer.confirm(registration)
  end

  def confirm_event
    RegistrationMailer.confirm(registration_ao)
  end

  private

  def registration
    Registration.last
  end

  def registration_ao
    Registration.all.select { |r| r.event.category == 'meeting' }.last
  end
end
