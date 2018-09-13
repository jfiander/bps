# frozen_string_literal: true

module User::Address
  def mailing_address(name: true)
    [
      (name ? full_name(html: false) : nil),
      address_1,
      address_2,
      "#{city} #{state} #{zip}"
    ].reject(&:blank?)
  end
end
