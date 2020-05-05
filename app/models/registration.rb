# frozen_string_literal: true

class Registration < ApplicationRecord
  payable
  belongs_to :user, optional: true
  belongs_to :event

  before_validation :convert_email_to_user

  validate :email_or_user_present, :no_duplicate_registrations

  scope :current,  -> { all.find_all { |r| !r.event&.expired? } }
  scope :expired,  -> { all.find_all { |r| r.event&.expired? } }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  after_create :notify_on_create
  after_create :confirm_to_registrant

  def payment_amount
    convert_email_to_user && save
    return override_cost if override_cost.present?

    event&.get_cost(user&.present?)
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

  def notify_on_create
    RegistrationMailer.registered(self).deliver
  end

  def confirm_to_registrant
    RegistrationMailer.confirm(self).deliver
  end

private

  def no_duplicate_registrations
    return if Registration.where(user: user, email: email, event: event).where.not(id: id).blank?

    errors.add(:base, 'Duplicate')
  end

  def public_registration?
    email.present? && user.blank?
  end

  def convert_email_to_user
    return unless public_registration?
    return unless (user = User.find_by(email: email))

    self.email = nil
    self.user = user
  end
end
