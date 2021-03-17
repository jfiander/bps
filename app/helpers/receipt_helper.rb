# frozen_string_literal: true

module ReceiptHelper
  def receipt_customer(payment)
    case payment&.customer
    when String
      mail_to(payment.customer)
    when User
      mail_to(payment.customer.email, payment.customer.full_name)
    when MemberApplicant
      mail_to(
        payment.customer.email, "#{payment.customer.first_name} #{payment.customer.last_name}"
      )
    end
  end

  def receipt_actions(payment)
    content_tag(:div, class: 'receipt-actions') do
      concat receipt_actions_paid_block(payment)
      concat receipt_actions_invoice_block(payment)
      concat receipt_actions_pay_now_block(payment)
    end
  end

  def receipt_amount(payment)
    title = 'Refunded' if payment.refunded

    content_tag(:div, class: "table-cell #{receipt_amount_color(payment)}", title: title) do
      concat payment.transaction_amount
      if payment.promo_code.present?
        concat tag(:br)
        concat receipt_promo_code(payment)
      end
    end
  end

private

  def receipt_actions_paid_block(payment)
    content_tag(:div, class: 'receipt-actions-block') do
      if payment.paid
        concat receipt_paid_icon(payment)
        concat receipt_mark_refunded_link(payment)
      elsif payment.parent.is_a?(Registration)
        concat receipt_cancel_registration_link(payment)
      end
    end
  end

  def receipt_actions_invoice_block(payment)
    content_tag(:div, class: 'receipt-actions-block') do
      if payment.paid
        concat receipt_link(payment)
      elsif !payment.refunded && payment.parent.is_a?(Registration)
        concat receipt_override_link(payment)
      end
    end
  end

  def receipt_actions_pay_now_block(payment)
    content_tag(:div, class: 'receipt-actions-block') do
      if !payment.paid && !payment.refunded
        concat receipt_pay_link(payment)
        concat receipt_paid_in_person_link(payment)
      end
    end
  end

  def receipt_paid_icon(payment)
    if payment.transaction_id == 'in-person'
      FA::Icon.p('money-check-alt', style: :duotone, fa: :fw, css: 'admin', title: 'Paid In-Person')
    else
      FA::Icon.p(
        'credit-card', style: :duotone, fa: :fw, css: 'green', title: 'Paid Online'
      )
    end
  end

  def receipt_mark_refunded_link(payment)
    return unless payment.paid && !payment.refunded

    link_to(refunded_path(payment.token), method: :patch, class: 'red', data: {
      confirm: 'Are you sure you want to mark this payment as refunded?'
    }) do
      FA::Icon.p('undo', style: :duotone, fa: :fw, title: 'Mark as refunded')
    end
  end

  def receipt_cancel_registration_link(payment)
    link_to(
      cancel_registration_path(payment.parent.id),
      class: 'red', method: :delete, remote: true, data: {
        confirm: 'Are you sure you want to cancel this registration?'
      }
    ) do
      FA::Icon.p('minus-square', style: :duotone, fa: :fw, title: 'Cancel registration')
    end
  end

  def receipt_link(payment)
    link_to(receipt_path(payment.token), class: 'blue') do
      if payment.receipt.exists?
        FA::Icon.p('file-pdf', style: :duotone, fa: :fw, title: 'Receipt')
      else
        FA::Icon.p('ellipsis-h', style: :duotone, fa: :fw, css: 'gray', title: 'Pending generation')
      end
    end
  end

  def receipt_override_link(payment)
    style = payment.parent&.override_cost.present? ? :solid : :duotone
    link_to(override_cost_path(payment.token), class: 'green') do
      FA::Icon.p('file-invoice-dollar', style: style, fa: :fw, title: 'Override Cost')
    end
  end

  def receipt_pay_link(payment)
    return not_payable_icon unless payment.payable?

    link_to(pay_path(payment.token)) do
      FA::Icon.p('credit-card', style: :duotone, fa: :fw, title: 'Pay Now')
    end
  end

  def not_payable_icon
    FA::Icon.p('ban', style: :duotone, fa: :fw, css: 'gray', title: 'Not payable')
  end

  def receipt_paid_in_person_link(payment)
    link_to(paid_in_person_path(payment.token), class: 'admin', data: {
      confirm: 'Are you sure you want to mark this payment as paid in-person?'
    }) do
      FA::Icon.p('money-check-alt', style: :duotone, fa: :fw, title: 'Paid In-Person')
    end
  end

  def receipt_amount_color(payment)
    if !payment.paid?
      'gray'
    elsif payment.refunded
      'red'
    end
  end

  def receipt_promo_code(payment)
    content_tag(:small, class: 'green') do
      concat FA::Icon.p('tags', style: :duotone)
      concat payment.promo_code.code
    end
  end
end
