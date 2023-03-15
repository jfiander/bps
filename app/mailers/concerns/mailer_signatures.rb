# frozen_string_literal: true

module MailerSignatures
  # This module defines no public methods.
  def _; end

private

  def ao_signature
    ao = BridgeOffice.find_by(office: 'administrative')&.user
    return commander_signature unless ao

    name = BridgeOffice.find_by(office: 'administrative').user.full_name
    email = 'ao@bpsd9.org'

    {
      office: 'Administrative Officer',
      name: name,
      email: email,
      from: "\"#{name}\" <#{email}>"
    }
  end

  def seo_signature
    seo = BridgeOffice.find_by(office: 'educational')&.user
    return commander_signature unless seo

    name = BridgeOffice.find_by(office: 'educational').user.full_name
    email = 'seo@bpsd9.org'

    {
      office: 'Educational Officer',
      name: name,
      email: email,
      from: "\"#{name}\" <#{email}>"
    }
  end

  def commander_signature
    name = BridgeOffice.find_by(office: 'commander').user.full_name
    email = 'cdr@bpsd9.org'

    {
      office: 'Commander',
      name: name,
      email: email,
      from: "\"#{name}\" <#{email}>"
    }
  end
end
