# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:token) { Payment.client_token }
  let(:user_token) { Payment.client_token(user_id: @user.id) }

  let(:braintree_api_token_regex) { %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/client_token 201} }
  let(:braintree_api_customer_regex) { %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/customers 201} }

  it 'should use the correct discount rate' do
    expect(Payment.discount(1)).to eql(0.32)
    expect(Payment.discount(100)).to eql(2.50)
    expect(Payment.discount(200)).to eql(4.70)
  end

  describe 'general methods' do
    it 'should return a Braintree gateway' do
      expect(Payment.gateway).to be_a(Braintree::Gateway)
    end

    it 'should return valid client_tokens' do
      @user = FactoryBot.create(:user)

      expect { @token = token }.to output(braintree_api_token_regex).to_stdout_from_any_process
      expect { @user_token = user_token }.to output(braintree_api_token_regex).to_stdout_from_any_process
      expect(@token).to be_a(String)
      expect(@user_token).to be_a(String)
      expect(@user_token.length).to be > @token.length
    end

    it 'should return a valid client_token when given a user_id' do
    end

    it 'should post the client_token request' do
      @user = FactoryBot.create(:user)
      expect { user_token }.to output(braintree_api_token_regex).to_stdout_from_any_process
    end

    it 'should post customer data' do
      @user = FactoryBot.create(:user)
      expect { user_token }.to output(braintree_api_customer_regex).to_stdout_from_any_process
    end

    describe 'paid?' do
      before(:each) do
        generic_seo_and_ao
        event = FactoryBot.create(:event)
        reg = FactoryBot.create(:registration, event: event, email: 'example@example.com')
        @payment = FactoryBot.create(:payment, parent: reg)
      end

      it 'should be false if not paid' do
        expect(@payment.paid?).to be(false)
      end

      it 'should be true if paid' do
        @payment.paid!('testing')
        expect(@payment.paid?).to be(true)
      end
    end
  end

  context 'registration' do
    before(:each) do
      generic_seo_and_ao
      @registration = FactoryBot.create(:registration, :with_user)
    end

    it 'should have the correct transaction amount' do
      expect(@registration.payment.transaction_amount).to eql("$#{@registration.payment_amount}.00")
    end

    it 'should correctly update a paid payment' do
      @registration.payment.paid!('09876')
      expect(@registration.payment.paid).to be(true)
      expect(@registration.payment.transaction_id).to eql('09876')
    end

    it 'should correctly set as paid in-person' do
      @registration.payment.in_person!
      expect(@registration.payment.paid).to be(true)
      expect(@registration.payment.transaction_id).to eql('in-person')
    end

    describe 'payable' do
      it 'should be payable when the parent is payable' do
        @registration.event.update(cost: 1)
        expect(@registration.payment.payable?).to eql(@registration.payable?)
        expect(@registration.payment.payable?).to be(true)
      end

      it 'should not be payable when the parent is not payable' do
        @registration.event.update(cost: 1, advance_payment: true, cutoff_at: Time.now - 1.hour)
        expect(@registration.payment.payable?).to eql(@registration.payable?)
        expect(@registration.payment.payable?).to be(false)
      end
    end
  end

  context 'membership application' do
    before(:each) do
      @application = FactoryBot.create(:member_application, :with_primary)
    end

    it 'should have the correct transaction amount' do
      expect(@application.payment.transaction_amount).to eql("$#{@application.payment_amount}.00")
    end

    it 'should correctly update a paid payment' do
      @application.payment.paid!('09876')
      expect(@application.payment.paid).to be(true)
      expect(@application.payment.transaction_id).to eql('09876')
    end
  end

  context 'annual dues' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @payment = FactoryBot.create(:payment, parent: @user)
    end

    it 'should have the correct transaction amount' do
      expect(@payment.transaction_amount).to eql("$#{@user.payment_amount}.00")
    end

    it 'should correctly update a paid payment' do
      @payment.paid!('09876')
      expect(@payment.paid).to be(true)
      expect(@payment.transaction_id).to eql('09876')
      expect(@user.dues_last_paid_at).to be > 5.seconds.ago
      expect(@user.dues_last_paid_at).to be < 5.seconds.since
    end
  end

  describe 'cost' do
    before(:each) do
      generic_seo_and_ao
    end

    it 'should return false if cost is a Hash' do
      parent = FactoryBot.create(:user)
      child = FactoryBot.create(:user, parent: parent)
      payment = FactoryBot.create(:payment, parent: child)

      expect(payment.cost?).to be(false)
    end

    it 'should return false if cost is nil' do
      event = FactoryBot.create(:event, cost: nil)
      reg = FactoryBot.create(:registration, event: event, email: 'example@example.com')
      payment = FactoryBot.create(:payment, parent: reg)

      expect(payment.cost?).to be(false)
    end

    it 'should return true if cost is an Integer' do
      event = FactoryBot.create(:event, cost: 7)
      reg = FactoryBot.create(:registration, event: event, email: 'example@example.com')
      payment = FactoryBot.create(:payment, parent: reg)

      expect(payment.cost?).to be(true)
    end
  end

  describe 'promo codes' do
    describe 'attach' do
      before(:each) do
        event_type = FactoryBot.create(:event_type)
        event = FactoryBot.create(:event, event_type: event_type)
        reg, _ = register(event, email: 'test@example.com')
        @payment = reg.payment
      end

      it 'should not have a promo code attached on create' do
        expect(@payment.promo_code).to be_blank
      end

      it 'should not attach a promo code if not usable' do
        FactoryBot.create(:promo_code, code: 'prior_code')
        @payment.attach_promo_code('prior_code')

        expect(@payment.promo_code).to be_blank
      end

      it 'should correctly attach a promo code when a match exists' do
        FactoryBot.create(:promo_code, code: 'prior_code', valid_at: Time.now - 1.hour, discount_type: 'member')
        @payment.attach_promo_code('prior_code')

        expect(@payment.promo_code.code).to eql('prior_code')
      end

      it 'should correctly attach a promo code when a match does not exist' do
        @payment.attach_promo_code('new_code', valid_at: Time.now - 1.hour, discount_type: 'member')

        expect(@payment.promo_code.code).to eql('new_code')
      end
    end

    it 'should use the discounted transaction amount' do
      event_type = FactoryBot.create(:event_type)
      event = FactoryBot.create(:event, event_type: event_type, cost: 20)
      reg, _ = register(event, email: 'test@example.com')
      payment = reg.payment
      payment.attach_promo_code('new_code', valid_at: Time.now - 1.hour, discount_type: 'percent', discount_amount: 5)

      expect(payment.transaction_amount).to eql('$19.00')
    end
  end
end
