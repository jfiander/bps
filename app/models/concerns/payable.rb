# frozen_string_literal: true

module Payable
  module ClassMethods
    def payable
      has_one :payment, foreign_key: :parent_id, dependent: :destroy
      before_destroy :block_destroy, if: :paid?
      after_create { self.payment = create_payment(parent: self) }
    end

    def payable?
      reflect_on_association(:payment).present?
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def paid?
    return nil unless self&.class&.payable?
    self&.payment&.paid
  end

  def payment_amount
    nil
  end

  def payable?
    payment&.present? && payment_amount&.to_i&.positive? && !paid? &&
      ENV['ENABLE_BRAINTREE'] == 'enabled'
  end

private

  def block_destroy
    raise "This #{self.class.name} has been paid, and cannot be destroyed."
  end
end
