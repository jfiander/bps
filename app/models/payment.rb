# frozen_string_literal: true

# Internal API for accessing Braintree payments.
class Payment < ApplicationRecord
  include Payments::ModelConfigs
  include Payments::BraintreeMethods

  belongs_to :parent, polymorphic: true
  has_secure_token

  has_attached_file(
    :receipt, paperclip_defaults(:files).merge(path: 'receipts/:id.pdf')
  )

  validates_attachment_content_type :receipt, content_type: %r{\Aapplication/pdf\z}

  scope :recent, -> { where('created_at > ?', 11.months.ago) }
  scope :for_user, ->(user) { where(parent_type: 'User', parent_id: user.id) }

  def self.discount(amount)
    # Fee is rounded down to the nearest cent
    fee = amount.to_d * 0.022 + 0.30
    fee.floor(2)
  end

  def amount
    parent&.payment_amount
  end

  def cost?
    !parent&.payment_amount&.is_a?(Hash) && parent&.payment_amount&.positive?
  end

  def transaction_amount
    amount.is_a?(Integer) ? "#{amount}.00" : amount
  end

  def discounted_amount
    transaction_amount.to_d - Payment.discount(transaction_amount)
  end

  def paid!(transaction_id)
    update(paid: true, transaction_id: transaction_id, cost_type: set_cost_type)
    receipt!

    # Post-payment hooks
    parent.dues_paid! if parent_type == 'User'
  end
  
  def customer
    case parent.class.name
    when 'MemberApplication'
      parent.primary
    when 'Registration'
      parent.user || parent.email
    when 'User'
      parent
    end
  end

  def receipt_link
    receipt.present? ? Payment.buckets[:files].link(receipt.s3_object.key) : '#'
  end

  def receipt!
    update!(receipt: BpsPdf::Receipt.create_pdf(self))
    receipt_link
  end

  private

  def set_cost_type
    return unless parent.class.name == 'Registration'
    parent.event.costs.select { |t, c| c == amount }.keys.first.to_s.titleize
  end
end
