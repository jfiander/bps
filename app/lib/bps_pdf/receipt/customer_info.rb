# frozen_string_literal: true

module BpsPdf::Receipt::CustomerInfo
private

  def customer_info(payment)
    bounding_box([0, 575], width: 300, height: 90) do
      text 'Customer Info', size: 18, style: :bold, align: :center
      move_down(10)
      customer = payment.customer
      customer.is_a?(String) ? customer_email(customer) : customer_name_and_email(customer)
    end
  end

  def customer_email(customer)
    text "<b>Email:</b> #{customer}", size: 14, inline_format: true
  end

  def customer_name_and_email(customer)
    text "<b>Name:</b> #{customer.first_name} #{customer.last_name}", size: 14, inline_format: true
    move_down(5)
    text "<b>Email:</b> #{customer.email}", size: 14, inline_format: true
  end
end
