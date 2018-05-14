module MailerSignatures
  private

  def ao_signature
    {
      office: 'Administrative',
      name: BridgeOffice.find_by(office: 'administrative').user.full_name,
      email: 'ao@bpsd9.org'
    }
  end

  def seo_signature
    {
      office: 'Educational',
      name: BridgeOffice.find_by(office: 'educational').user.full_name,
      email: 'seo@bpsd9.org'
    }
  end
end
