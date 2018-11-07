# frozen_string_literal: true

class UserRegistration < ApplicationRecord
  belongs_to :registration
  belongs_to :user, optional: true

  before_validation :convert_email_to_user
  before_destroy :block_destroy, if: :paid?

  validates :primary, uniqueness: { scope: :registration }
  validate :has_user_or_email?, :no_duplicates

private

  def paid?
    registration.paid?
  end

  def block_destroy
    raise 'The associated registration has been paid, so this cannot be destroyed.'
  end

  def has_user_or_email?
    return true if user.present? || email.present?

    errors.add(:user, 'or email must be present')
  end

  def no_duplicates
    return if UserRegistration.where(user: user, email: email, registration: registration)
                              .where.not(id: id).blank?

    errors.add(:base, 'Duplicate')
  end

  def convert_email_to_user
    return unless email.present? && user.blank?
    return unless (user = User.find_by(email: email))

    self.user = user
    self.email = nil
  end
end
