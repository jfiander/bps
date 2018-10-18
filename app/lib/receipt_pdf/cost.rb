# frozen_string_literal: true

module ReceiptPDF::Cost
  private

  def cost(payment)
    bounding_box([0, 445 - people_height(payment)], width: 550, height: 100) do
      amount_paid(payment)
      move_down(5)
      cost_type(payment)
      override_comment(payment)
    end
  end

  def amount_paid(payment)
    text 'Amount Paid', size: 18, style: :bold, align: :center
    move_down(10)
    text "<b>$ #{payment.amount}</b>", size: 14, align: :center, inline_format: true
  end

  def cost_type(payment)
    return unless payment.cost_type.present? || payment.cost_type == 'General'
    text payment.cost_type, size: 12, align: :center, inline_format: true
  end

  def override_comment(payment)
    return unless payment.parent.respond_to?(:override_comment)
    return unless payment.parent.override_comment&.present?
    text payment.parent.override_comment, size: 12, align: :center, inline_format: true
  end
end
