# frozen_string_literal: true

class Registration < ApplicationRecord
  payable

  belongs_to :event
  has_many :user_registrations
  accepts_nested_attributes_for :user_registrations

  validates :user_registrations, presence: true

  scope :with_users, -> { includes(user_registrations: :user) }

  def self.current
    where(id: Event.where('expires_at < ?', Time.now).select(:id))
  end

  def self.expired
    where(id: Event.where('expires_at >= ?', Time.now).select(:id))
  end

  def self.register(event: nil, event_id: nil, user: nil, email: nil)
    validate_registration(event, event_id, user, email)
    event_id ||= event.id

    regs = Registration.where(event_id: event_id)
    ur = UserRegistration.find_by(registration: regs, user: user, email: email)
    return ur.registration if ur.present?

    reg = Registration.new(event_id: event_id)
    ur = UserRegistration.new(registration: reg, primary: true, user: user, email: email)
    reg.user_registrations << ur
    reg.save
    ur.save
    reg
  end

  def self.validate_registration(event, event_id, user, email)
    raise ArgumentError, 'Must specify a user or email' unless user.present? || email.present?
    return if event.present? || event_id.present?

    raise ArgumentError, 'Must specify an event or event_id'
  end

  def self.for_user(user)
    with_users.where(user_registrations: { user_id: user })
  end

  def add(user: nil, email: nil, certificate: nil)
    self.user_registrations << UserRegistration.create(
      registration: self, primary: false, user: user, email: email, certificate: certificate
    )
    save
    self
  end

  def primary
    user_registrations.select { |u| u.primary }.first
  end

  def payment_amount
    return override_cost if override_cost.present?

    user_registrations.size * event&.get_cost(primary&.user&.present?)
  end

  def cost?
    payment_amount&.positive?
  end

  def user?
    user.present?
  end

  def type
    event.course? ? 'course' : event.event_type.event_category
  end

  def payable?
    super && !(event.cutoff? && event.advance_payment)
  end

  def user
    primary&.user
  end

  def email
    primary&.email
  end

  def notify_new
    RegistrationMailer.registered(self).deliver
  end

  def confirm_to_registrants
    # user_registrations.each { |ur| RegistrationMailer.confirm(ur).deliver }
    RegistrationMailer.confirm(self).deliver
  end
end
