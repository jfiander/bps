# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:token) { described_class.client_token }
  let(:user_token) { described_class.client_token(user_id: user.id) }

  let(:braintree_api_token_regex) { %r{POST /merchants/#{ENV.fetch('BRAINTREE_MERCHANT_ID', nil)}/client_token 201} }
  let(:braintree_api_customer_regex) { %r{POST /merchants/#{ENV.fetch('BRAINTREE_MERCHANT_ID', nil)}/customers 201} }

  it 'uses the correct discount rate' do
    expect(described_class.discount(1)).to eq(0.32)
    expect(described_class.discount(100)).to eq(2.50)
    expect(described_class.discount(200)).to eq(4.70)
  end

  describe 'general methods' do
    it 'returns a Braintree gateway' do
      expect(described_class.gateway).to be_a(Braintree::Gateway)
    end

    it 'returns valid client_tokens' do
      expect { token }.to output(braintree_api_token_regex).to_stdout_from_any_process
      expect { user_token }.to output(braintree_api_token_regex).to_stdout_from_any_process
      expect(token).to be_a(String)
      expect(user_token).to be_a(String)
      expect(user_token.length).to be > token.length
    end

    it 'posts the client_token request' do
      expect { user_token }.to output(braintree_api_token_regex).to_stdout_from_any_process
    end

    it 'posts customer data' do
      expect { user_token }.to output(braintree_api_customer_regex).to_stdout_from_any_process
    end

    describe 'paid?' do
      let(:payment) do
        generic_seo_and_ao
        event = FactoryBot.create(:event)
        reg = FactoryBot.create(:registration, event: event, email: 'example@example.com')
        FactoryBot.create(:payment, parent: reg)
      end

      it 'is false if not paid' do
        expect(payment.paid?).to be(false)
      end

      it 'is true if paid' do
        payment.paid!('testing')
        expect(payment.paid?).to be(true)
      end
    end
  end

  context 'with a registration' do
    let(:registration) do
      generic_seo_and_ao
      FactoryBot.create(:registration, :with_user)
    end

    it 'has the correct transaction amount' do
      expect(registration.payment.transaction_amount).to eql("$#{registration.payment_amount}.00")
    end

    it 'correctlies update a paid payment' do
      registration.payment.paid!('09876')
      expect(registration.payment.paid).to be(true)
      expect(registration.payment.transaction_id).to eql('09876')
    end

    it 'correctlies set as paid in-person' do
      registration.payment.in_person!
      expect(registration.payment.paid).to be(true)
      expect(registration.payment.transaction_id).to eql('in-person')
    end

    describe 'payable' do
      it 'is payable when the parent is payable' do
        registration.event.update(cost: 1)
        expect(registration.payment.payable?).to eql(registration.payable?)
        expect(registration.payment.payable?).to be(true)
      end

      it 'is not payable when the parent is not payable' do
        registration.event.update(cost: 1, advance_payment: true, cutoff_at: 1.hour.ago)
        expect(registration.payment.payable?).to eql(registration.payable?)
        expect(registration.payment.payable?).to be(false)
      end
    end
  end

  context 'with a membership application' do
    let(:application) { FactoryBot.create(:member_application, :with_primary) }

    it 'has the correct transaction amount' do
      expect(application.payment.transaction_amount).to eql("$#{application.payment_amount}.00")
    end

    it 'correctlies update a paid payment' do
      application.payment.paid!('09876')
      expect(application.payment.paid).to be(true)
      expect(application.payment.transaction_id).to eql('09876')
    end
  end

  context 'with annual dues' do
    let(:payment) { FactoryBot.create(:payment, parent: user) }

    it 'has the correct transaction amount' do
      expect(payment.transaction_amount).to eql("$#{user.payment_amount}.00")
    end

    it 'correctlies update a paid payment' do
      payment.paid!('09876')
      expect(payment.paid).to be(true)
      expect(payment.transaction_id).to eql('09876')
      expect(user.dues_last_paid_at).to be > 5.seconds.ago
      expect(user.dues_last_paid_at).to be < 5.seconds.since
    end
  end

  describe 'cost' do
    before { generic_seo_and_ao }

    it 'returns false if cost is a Hash' do
      parent = FactoryBot.create(:user)
      child = FactoryBot.create(:user, parent: parent)
      payment = FactoryBot.create(:payment, parent: child)

      expect(payment.cost?).to be(false)
    end

    it 'returns false if cost is nil' do
      event = FactoryBot.create(:event, cost: nil)
      reg = FactoryBot.create(:registration, event: event, email: 'example@example.com')
      payment = FactoryBot.create(:payment, parent: reg)

      expect(payment.cost?).to be(false)
    end

    it 'returns true if cost is an Integer' do
      event = FactoryBot.create(:event, cost: 7)
      reg = FactoryBot.create(:registration, event: event, email: 'example@example.com')
      payment = FactoryBot.create(:payment, parent: reg)

      expect(payment.cost?).to be(true)
    end
  end

  describe 'promo codes' do
    before { generic_seo_and_ao }

    describe 'attach' do
      let(:payment) do
        event_type = FactoryBot.create(:event_type)
        event = FactoryBot.create(:event, event_type: event_type)
        reg, = register(event, email: 'test@example.com')
        reg.payment
      end

      it 'does not have a promo code attached on create' do
        expect(payment.promo_code).to be_blank
      end

      it 'does not attach a promo code if not usable' do
        FactoryBot.create(:promo_code, code: 'prior_code')
        payment.attach_promo_code('prior_code')

        expect(payment.promo_code).to be_blank
      end

      it 'correctlies attach a promo code when a match exists' do
        FactoryBot.create(:promo_code, code: 'prior_code', valid_at: 1.hour.ago, discount_type: 'member')
        payment.attach_promo_code('prior_code')

        expect(payment.promo_code.code).to eql('prior_code')
      end

      it 'correctlies attach a promo code when a match does not exist' do
        payment.attach_promo_code('new_code', valid_at: 1.hour.ago, discount_type: 'member')

        expect(payment.promo_code.code).to eql('new_code')
      end
    end

    it 'uses the discounted transaction amount' do
      event_type = FactoryBot.create(:event_type)
      event = FactoryBot.create(:event, event_type: event_type, cost: 20)
      reg, = register(event, email: 'test@example.com')
      payment = reg.payment
      payment.attach_promo_code(
        'new_code', valid_at: 1.hour.ago, discount_type: 'percent', discount_amount: 5
      )

      expect(payment.transaction_amount).to eql('$19.00')
    end
  end
end
