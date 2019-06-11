# frozen_string_literal: true

class UserRegistration < ApplicationRecord
  belongs_to :registration
  has_one :event, through: :registration
  belongs_to :user, optional: true
  attr_accessor :certificate

  before_validation :convert_email_to_user
  before_validation :convert_certificate_to_user
  before_destroy :block_destroy, if: :paid?

  validates_uniqueness_of :primary, if: :primary, scope: :registration_id
  validate :user_or_email?, :no_duplicates

  def paid?
    registration.paid?
  end

private

  def block_destroy
    raise 'The associated registration has been paid, so this cannot be destroyed.'
  end

  def user_or_email?
    return true if user.present? || email.present?

    errors.add(:user, 'or email must be present')
  end

  def no_duplicates
    match = UserRegistration.where(registration: registration, user: user) if user
    match ||= UserRegistration.where(registration: registration, email: email) if email
    return if match.blank?

    errors.add(:base, 'Duplicate')
  end

  def convert_email_to_user
    return unless email.present? && user.blank?
    return unless (user = User.find_by(email: email))

    self.user = user
    self.email = nil
  end

  def convert_certificate_to_user
    return unless certificate.present?
    return unless (user = User.find_by(certificate: certificate.to_s.upcase))

    self.user = user
    self.certificate = nil
  end
end
