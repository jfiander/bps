# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericPaymentMailer, type: :mailer do
  let(:generic_payment) { FactoryBot.create(:generic_payment, email: 'nobody@example.com') }
  let(:mail) { described_class.paid(generic_payment) }

  it 'renders the headers' do
    expect(mail).to contain_mail_headers(
      subject: 'Payment received',
      to: ['treasurer@bpsd9.org', 'webmaster@bpsd9.org'],
      from: ['support@bpsd9.org']
    )
  end

  it 'renders the body' do
    expect(mail.body.encoded).to contain_and_match(
      'Someone has submitted a payment.', 'Generic Payment'
    )
  end
end
