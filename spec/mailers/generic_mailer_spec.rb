# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericMailer do
  let(:user) { create(:user) }
  let(:mail) { described_class.generic_message(user, 'This is a test message.') }

  it 'renders the headers' do
    expect(mail).to contain_mail_headers(
      subject: "A Message from America's Boating Club - Birmingham Squadron",
      to: [user.email],
      from: ['support@bpsd9.org']
    )
  end

  it 'renders the body' do
    expect(mail.body.encoded).to contain_and_match(
      "A Message from America's Boating Club - Birmingham Squadron", 'This is a test message.'
    )
  end
end
