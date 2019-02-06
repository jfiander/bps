# frozen_string_literal: true

class RegistrationMailerPreview < ApplicationMailerPreview
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
    RegistrationMailer.confirm(ur(reg_member_event))
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
    RegistrationMailer.confirm(ur(reg_member_free))
  end

  def confirm_member_paid
    RegistrationMailer.confirm(ur(reg_member_paid))
  end

  def confirm_public_free
    RegistrationMailer.confirm(ur(reg_public_free))
  end

  def confirm_public_paid
    RegistrationMailer.confirm(ur(reg_public_paid))
  end

  def request_schedule
    RegistrationMailer.request_schedule(
      EventType.new(event_category: 'seminar', title: 'Example'), by: user
    )
  end

private

  def reg_member_free
    # Registration.includes(:user_registrations).where.not(user_registrations: { user: nil })
    #             .select { |r| !r.payable? }.last
    new_registration(event: event, user: user)
  end

  def reg_member_event
    new_registration(event: event(category: 'meeting'), user: user)
  end

  def reg_member_paid
    # Registration.includes(:user_registrations).where.not(user_registrations: { user: nil })
    #             .select(&:payable?).last
    new_registration(event: event(cost: 5), user: user)
  end

  def reg_member_already_paid
    # Registration.includes(:user_registrations).where.not(user_registrations: { user: nil })
    #             .select(&:paid?).last
    new_registration(event: event(cost: 5), user: user, paid: true)
  end

  def reg_public_free
    # Registration.includes(:user_registrations).where(user_registrations: { user: nil })
    #             .select { |r| !r.payable? }.last
    new_registration(event: event, email: email)
  end

  def reg_public_paid
    # Registration.includes(:user_registrations).where(user_registrations: { user: nil })
    #             .select(&:payable?).last
    new_registration(event: event(cost: 5), email: email)
  end

  def new_registration(event:, user: nil, email: nil, paid: false)
    reg = Registration.new(event: event)
    reg.user_registrations << UserRegistration.new(registration: reg, user: user, email: email, primary: true)
    reg.payment = Payment.new
    reg.payment.update(paid: true) if paid
    reg
  end

  def event(category: 'seminar', cost: nil)
    event_type = EventType.new(event_category: category, title: 'Example')
    Event.new(event_type: event_type, start_at: Time.now + 1.week, cost: cost)
  end

  def ur(reg)
    reg.user_registrations.first
  end
end
