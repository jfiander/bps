# frozen_string_literal: true

module BpsPdf::Receipt::PolicyLinks
  private

  def policy_links(payment)
    policy_links_left(payment)
    policy_links_right(payment)
  end

  def policy_links_left(payment)
    bounding_box([0, 80], width: 325, height: 80) do
      terms_link
      move_down(20)
      security_link
    end
  end

  def policy_links_right(payment)
    bounding_box([325, 80], width: 225, height: 80) do
      refund_link
      move_down(20)
      mail_link
    end
  end

  def terms_link
    text 'Terms & Conditions', size: 12, align: :center, inline_format: true
    text "https://#{ENV['DOMAIN']}/payment_terms", size: 10, align: :center
  end

  def refund_link
    text 'Refund Policy', size: 12, align: :center, inline_format: true
    text "https://#{ENV['DOMAIN']}/refunds", size: 10, align: :center
  end

  def security_link
    text 'Data Security', size: 12, align: :center, inline_format: true
    text "https://www.braintreepayments.com/features/data-security", size: 10, align: :center
  end

  def mail_link
    text 'Contact us', size: 12, align: :center, inline_format: true
    text "payments@bpsd9.org", size: 10, align: :center
  end
end
