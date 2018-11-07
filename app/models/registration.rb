# frozen_string_literal: true

class Registration < ApplicationRecord
  payable

  belongs_to :event
  has_many :user_registrations

  scope :current,  -> { all.find_all { |r| !r.event&.expired? } }
  scope :expired,  -> { all.find_all { |r| r.event&.expired? } }

  after_create :notify_on_create
  after_create :confirm_to_registrants

  def self.for_user(user_id)
    UserRegistration.where(user_id: user_id).map(&:registration)
  end

  def payment_amount
    return override_cost if override_cost.present?

    user_registrations.count * event&.get_cost(user_registrations&.primary&.user&.present?)
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
    user_registrations.find_by(prinary: true)
  end

private

  def notify_on_create
    RegistrationMailer.registered(self).deliver
  end

  def confirm_to_registrants
    user_registrations.each { |ur| RegistrationMailer.confirm(ur).deliver }
  end
end
