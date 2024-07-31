# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment do
  let(:user) { create(:user) }
  let(:token) { described_class.client_token }
  let(:user_token) { described_class.client_token(user_id: user.id) }

  let(:braintree_api_token_regex) { %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/client_token 201} }
  let(:braintree_api_customer_regex) { %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/customers 201} }

  it 'uses the correct discount rate' do
    discounts = {
      1 => 0.50,
      100 => 2.48,
      200 => 4.47,

      # Actual discount rates from Braintree
      25 => 0.98,
      35 => 1.18,
      45 => 1.38,
      50 => 1.48,
      70 => 1.88,
      89 => 2.26
    }

    expect(discounts.keys.map { |v| described_class.discount(v) }).to eq(discounts.values)
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
        event = create(:event)
        reg = create(:registration, event: event, email: 'example@example.com')
        create(:payment, parent: reg)
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
      create(:registration, :with_user)
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
    let(:application) { create(:member_application, :with_primary) }

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
    let(:payment) { create(:payment, parent: user) }

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
      parent = create(:user)
      child = create(:user, parent: parent)
      payment = create(:payment, parent: child)

      expect(payment.cost?).to be(false)
    end

    it 'returns false if cost is nil' do
      event = create(:event, cost: nil)
      reg = create(:registration, event: event, email: 'example@example.com')
      payment = create(:payment, parent: reg)

      expect(payment.cost?).to be(false)
    end

    it 'returns true if cost is an Integer' do
      event = create(:event, cost: 7)
      reg = create(:registration, event: event, email: 'example@example.com')
      payment = create(:payment, parent: reg)

      expect(payment.cost?).to be(true)
    end
  end

  describe 'promo codes' do
    before { generic_seo_and_ao }

    describe 'attach' do
      let(:payment) do
        event_type = create(:event_type)
        event = create(:event, event_type: event_type)
        reg, = register(event, email: 'test@example.com')
        reg.payment
      end

      it 'does not have a promo code attached on create' do
        expect(payment.promo_code).to be_blank
      end

      it 'does not attach a promo code if not usable' do
        create(:promo_code, code: 'prior_code')
        payment.attach_promo_code('prior_code')

        expect(payment.promo_code).to be_blank
      end

      it 'correctlies attach a promo code when a match exists' do
        create(:promo_code, code: 'prior_code', valid_at: 1.hour.ago, discount_type: 'member')
        payment.attach_promo_code('prior_code')

        expect(payment.promo_code.code).to eql('prior_code')
      end

      it 'correctlies attach a promo code when a match does not exist' do
        payment.attach_promo_code('new_code', valid_at: 1.hour.ago, discount_type: 'member')

        expect(payment.promo_code.code).to eql('new_code')
      end
    end

    it 'uses the discounted transaction amount' do
      event_type = create(:event_type)
      event = create(:event, event_type: event_type, cost: 20)
      reg, = register(event, email: 'test@example.com')
      payment = reg.payment
      payment.attach_promo_code(
        'new_code', valid_at: 1.hour.ago, discount_type: 'percent', discount_amount: 5
      )

      expect(payment.transaction_amount).to eql('$19.00')
    end
  end
end
