# frozen_string_literal: true

class RegistrationMailerPreview < ApplicationMailerPreview
  def registered
    RegistrationMailer.registered(reg_member_free)
  end

  def registered_paid
    RegistrationMailer.registered(reg_member_paid)
  end

  def registered_paid_selection
    RegistrationMailer.registered(reg_member_paid_selection)
  end

  def registered_paid_public
    RegistrationMailer.registered(reg_public_advance)
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

  def confirm_event_public
    RegistrationMailer.confirm(reg_public_advance)
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

  def confirm_member_paid_selection
    RegistrationMailer.confirm(reg_member_paid_selection)
  end

  def confirm_public_free
    RegistrationMailer.confirm(reg_public_free)
  end

  def confirm_public_paid
    RegistrationMailer.confirm(reg_public_paid)
  end

  def confirm_public_paid_with_important_notes
    reg = reg_public_paid
    reg.event.important_notes = 'This is something **important**.'
    RegistrationMailer.confirm(reg)
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

  def reg_member_paid_selection
    event = event(cost: 5)
    event.location = Location.new(address: 'Somewhere')
    selection = event.event_selections.build(description: 'Meal Selection')
    selection.event_options.build([{ name: 'Chicken' }, { name: 'Whitefish' }])
    registration = new_registration(event: event, user: user)
    registration.registration_options.build(event_option: selection.event_options.first)
    registration
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
    new_registration(
      event: event(cost: 5, advance: true),
      email: email, name: 'Somebody Doe', phone: '123 456-7890'
    )
  end

  def reg_public_multi_session
    new_registration(event: event(cost: 5, sessions: 2), email: email)
  end

  def new_registration(event:, **options)
    options = { user: nil, email: nil, name: nil, phone: nil, paid: false }.merge(options)
    paid = options.delete(:paid)
    Registration.new(event: event, **options).tap do |reg|
      reg.payment = Payment.new(token: SecureRandom.base58(24), paid: paid)
    end
  end

  def event(category: 'seminar', cost: nil, sessions: 1, advance: false)
    event_type = EventType.new(event_category: category, title: 'Example')
    Event.new(
      event_type: event_type,
      start_at: 1.week.from_now, cutoff_at: 3.days.from_now,
      cost: cost,
      sessions: sessions,
      advance_payment: advance,
      topic_arn: 'skip', google_calendar_event_id: 'skip'
    )
  end
end
