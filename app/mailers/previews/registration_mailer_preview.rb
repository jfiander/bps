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
    RegistrationMailer.confirm(reg_member_event)
  end

  def advance_payment
    RegistrationMailer.advance_payment(reg_public_advance)
  end

  def advance_payment_member
    RegistrationMailer.advance_payment(reg_member_advance)
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

  def confirm_multi_session
    RegistrationMailer.confirm(reg_public_multi_session)
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

  def reg_member_advance
    new_registration(event: event(category: 'meeting', cost: 5, advance: true), user: user)
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

  def reg_public_advance
    new_registration(event: event(cost: 5, advance: true), email: email)
  end

  def reg_public_multi_session
    new_registration(event: event(cost: 5, sessions: 2), email: email)
  end

  def new_registration(event:, user: nil, email: nil, paid: false)
    reg = Registration.new(event: event, user: user, email: email)
    reg.payment = Payment.new(token: SecureRandom.base58(24), paid: paid)
    reg
  end

  def event(category: 'seminar', cost: nil, sessions: 1, advance: false)
    event_type = EventType.new(event_category: category, title: 'Example')
    Event.new(
      event_type: event_type,
      start_at: Time.now + 1.week, cutoff_at: Time.now + 3.days,
      cost: cost,
      sessions: sessions,
      advance_payment: advance,
      topic_arn: 'skip', google_calendar_event_id: 'skip'
    )
  end
end
