# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationHelper, type: :helper do
  let(:event) { FactoryBot.create(:event, cost: 15) }
  let(:registration) { FactoryBot.create(:registration, event: event, email: 'nobody@example.com') }

  before { generic_seo_and_ao }

  describe '#pay_reg_link' do
    subject(:link) { described_class.pay_reg_link(registration) }

    it 'generates a valid pay link' do
      expect(link).to match(%r{/pay/#{registration.payment.token}})
    end

    it 'does not generate a link for a paid registration' do
      registration.payment.in_person!

      expect(link).to eq(described_class.send(:paid_icon))
    end
  end

  describe '#cancel_reg_link' do
    subject(:link) { described_class.cancel_reg_link(registration) }

    it 'generates a valid cancel link' do
      expect(link).to match(%r{/register/#{registration.id}})
      expect(link).to match(/method="delete"/)
    end

    it 'does not generate a link for a paid registration' do
      registration.payment.in_person!

      expect(link).to be_nil
    end
  end

  describe '#subscribe_reg_link' do
    subject(:link) { described_class.subscribe_reg_link(registration) }

    let(:user) { FactoryBot.create(:user, phone_c: '555-555-5555') }
    let(:registration) { FactoryBot.create(:registration, event: event, user: user) }

    it 'generates a valid subscribe link' do
      expect(link).to match(%r{/subscribe/#{registration.id}})
    end

    it 'generates a valid unsubscribe link' do
      registration.subscription_arn = 'arn:aws:sns:us-east-1:000000000000:name:00000000-0000-0000-0000-000000000000'

      expect(link).to match(%r{/unsubscribe/#{registration.id}})
    end

    it 'returns nil without a phone_c for the user' do
      user.phone_c = nil

      expect(link).to be_nil
    end
  end
end
