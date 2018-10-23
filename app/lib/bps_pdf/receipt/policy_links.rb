# frozen_string_literal: true

module BpsPdf::Receipt::PolicyLinks
private

  def policy_links(_payment)
    policy_links_left
    policy_links_right
  end

  def policy_links_left
    bounding_box([0, 80], width: 325, height: 80) do
      terms_link
      move_down(20)
      security_link
    end
  end

  def policy_links_right
    bounding_box([325, 80], width: 225, height: 80) do
      refund_link
      move_down(20)
      mail_link
    end
  end

  def terms_link
    text_with_fa('Terms & Conditions', "\uf15c")
    text "https://#{ENV['DOMAIN']}/payment_terms", size: 10, align: :center
  end

  def refund_link
    text_with_fa('Refund Policy', "\uf571")
    text "https://#{ENV['DOMAIN']}/refunds", size: 10, align: :center
  end

  def security_link
    text_with_fa('Data Security', "\uf023")
    text 'https://www.braintreepayments.com/features/data-security', size: 10, align: :center
  end

  def mail_link
    text_with_fa('Contact Us', "\uf0e0")
    text 'payments@bpsd9.org', size: 10, align: :center
  end

  def text_with_fa(text, icon_unicode)
    formatted_text(
      [
        { text: icon_unicode, inline_format: true, font: 'FontAwesome Pro Regular' },
        { text: " #{text}" }
      ], size: 12, align: :center
    )
  end
end
