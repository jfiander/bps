# frozen_string_literal: true

class RegistrationMailerPreview < ActionMailer::Preview
  def registered
    RegistrationMailer.registered(reg_member_free)
  end

  def registered_paid
    RegistrationMailer.registered(reg_member_paid)
  end

  def cancelled
    RegistrationMailer.cancelled(reg_member_free)
  end

  def paid
    RegistrationMailer.paid(reg_member_paid)
  end

  def confirm_event
    RegistrationMailer.confirm(registration_ao)
  end

  def remind_public
    RegistrationMailer.remind(reg_public_free)
  end

  def remind_member
    RegistrationMailer.remind(reg_member_paid)
  end

  def remind_member_paid
    RegistrationMailer.remind(reg_member_already_paid)
  end

  def confirm_member_free
    RegistrationMailer.confirm(reg_member_free)
  end

  def confirm_member_paid
    RegistrationMailer.confirm(reg_member_paid)
  end

  def confirm_public_free
    RegistrationMailer.confirm(reg_public_free)
  end

  def confirm_public_paid
    RegistrationMailer.confirm(reg_public_paid)
  end

  def request_schedule
    RegistrationMailer.request_schedule(EventType.last, by: User.first)
  end

private

  def reg_member_free
    Registration.where.not(user: nil).select { |r| !r.payable? }.last
  end

  def reg_member_paid
    Registration.where.not(user: nil).select(&:payable?).last
  end

  def reg_member_already_paid
    Registration.includes(:user_registrations).where.not(user_registrations: { user: nil })
                .select(&:paid?).last
  end

  def reg_public_free
    Registration.where(user: nil).select { |r| !r.payable? }.last
  end

  def reg_public_paid
    Registration.where(user: nil).select(&:payable?).last
  end

  def registration_ao
    Registration.all.select { |r| r.event.category == 'meeting' }.last
  end
end
