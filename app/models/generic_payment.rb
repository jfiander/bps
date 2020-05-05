# frozen_string_literal: true

class GenericPayment < ApplicationRecord
  payable
  belongs_to :user, optional: true

  before_validation :convert_email_to_user

  validates :description, presence: true
  validate :email_or_user_present

  scope :for_user, ->(user_id) { where(user_id: user_id) }

  def payment_amount
    amount
  end

  def link
    Rails.application.routes.url_helpers.pay_url(token: payment.token)
  end

private

  def convert_email_to_user
    return unless (user = User.find_by(email: email))

    self.email = nil
    self.user = user
  end
end
