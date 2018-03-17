module Address
  def mailing_address
    [
      full_name,
      address_1,
      address_2,
      "#{city} #{state} #{zip}"
    ].reject(&:blank?)
  end
end
