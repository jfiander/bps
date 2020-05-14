# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationHelper, type: :helper do
  let(:registration) do
    event = FactoryBot.create(:event, cost: 15)
    FactoryBot.create(:registration, event: event, email: 'nobody@example.com')
  end

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
end
