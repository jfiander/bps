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
    formatted_text(
      [
        { text: "\uf15c", inline_format: true, font: 'FontAwesome Pro Regular' },
        { text: ' Terms & Conditions', inline_format: true }
      ], size: 12, align: :center
    )
    text "https://#{ENV['DOMAIN']}/payment_terms", size: 10, align: :center
  end

  def refund_link
    formatted_text(
      [
        { text: "\uf571", inline_format: true, font: 'FontAwesome Pro Regular' },
        { text: ' Refund Policy' }
      ], size: 12, align: :center
    )
    text "https://#{ENV['DOMAIN']}/refunds", size: 10, align: :center
  end

  def security_link
    formatted_text(
      [
        { text: "\uf023", inline_format: true, font: 'FontAwesome Pro Regular' },
        { text: ' Data Security' }
      ], size: 12, align: :center
    )
    text "https://www.braintreepayments.com/features/data-security", size: 10, align: :center
  end

  def mail_link
    formatted_text(
      [
        { text: "\uf0e0", inline_format: true, font: 'FontAwesome Pro Regular' },
        { text: ' Contact Us' }
      ], size: 12, align: :center
    )
    text "payments@bpsd9.org", size: 10, align: :center
  end
end
