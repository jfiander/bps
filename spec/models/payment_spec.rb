require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:token) { Payment.client_token }
  let(:user_token) { Payment.client_token(user_id: @user.id) }

  it 'should use the correct discount rate' do
    expect(Payment.discount(1)).to eql(0.32)
    expect(Payment.discount(100)).to eql(2.50)
    expect(Payment.discount(200)).to eql(4.70)
  end

  describe 'general methods' do
    it 'should return a Braintree gateway' do
      expect(Payment.gateway).to be_a(Braintree::Gateway)
    end

    it 'should return a valid client_token' do
      expect { token }.to output(
        %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/client_token 201}
      ).to_stdout_from_any_process

      expect(token).to be_a(String)
      expect(token.length).to eql(1940)
    end

    it 'should return a valid client_token when given a user_id' do
      @user = FactoryBot.create(:user)
      expect { user_token }.to output(
        %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/client_token 201}
      ).to_stdout_from_any_process

      expect(user_token).to be_a(String)
      expect(user_token.length).to eql(2020)
    end

    it 'should post the client_token request' do
      @user = FactoryBot.create(:user)
      expect { user_token }.to output(
        %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/client_token 201}
      ).to_stdout_from_any_process
    end

    it 'should post customer data' do
      @user = FactoryBot.create(:user)
      expect { user_token }.to output(
        %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/customers 201}
      ).to_stdout_from_any_process
    end
  end

  context 'registration' do
    before(:each) do
      generic_seo_and_ao
      @registration = FactoryBot.create(:registration, :with_user)
    end

    it 'should have the correct transaction amount' do
      expect(@registration.payment.transaction_amount).to eql(
        "#{@registration.payment_amount}.00"
      )
    end

    it 'should correctly update a paid payment' do
      @registration.payment.paid!('09876')
      expect(@registration.payment.paid).to be(true)
      expect(@registration.payment.transaction_id).to eql('09876')
    end
  end

  context 'membership application' do
    before(:each) do
      @application = FactoryBot.create(:member_application, :with_primary)
    end

    it 'should have the correct transaction amount' do
      expect(@application.payment.transaction_amount).to eql(
        "#{@application.payment_amount}.00"
      )
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
      expect(@payment.transaction_amount).to eql(
        "#{@user.payment_amount}.00"
      )
    end

    it 'should correctly update a paid payment' do
      @payment.paid!('09876')
      expect(@payment.paid).to be(true)
      expect(@payment.transaction_id).to eql('09876')
      expect(@user.dues_last_paid_at).to be > 5.seconds.ago
      expect(@user.dues_last_paid_at).to be < 5.seconds.since
    end
  end
end
