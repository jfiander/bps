# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromoCode, type: :model do
  before(:each) do
    @promo_code = FactoryBot.create(:promo_code, code: 'testing')
  end

  describe 'flags' do
    describe 'pending' do
      it 'should be pending without a valid_at date' do
        expect(@promo_code).to be_pending
      end

      it 'should be pending with a future valid_at date' do
        @promo_code.update(valid_at: Time.now + 1.hour)
        expect(@promo_code).to be_pending
      end

      it 'should not be pending with a past valid_at date' do
        @promo_code.update(valid_at: Time.now - 1.hour)
        expect(@promo_code).not_to be_pending
      end
    end

    describe 'active' do
      it 'should be active with a past valid_at date and no expires_at date' do
        @promo_code.update(valid_at: Time.now - 1.hour)
        expect(@promo_code).to be_active
      end

      it 'should be active with a past valid_at date and future expires_at date' do
        @promo_code.update(valid_at: Time.now - 1.hour, expires_at: Time.now + 1.hour)
        expect(@promo_code).to be_active
      end

      it 'should not be active without a valid_at date' do
        expect(@promo_code).not_to be_active
      end

      it 'should not be active with a past expires_at date' do
        @promo_code.update(expires_at: Time.now - 1.hour)
        expect(@promo_code).not_to be_active
      end
    end

    describe 'expired' do
      it 'should not be expired without an expires_at date' do
        expect(@promo_code).not_to be_expired
      end

      it 'should not be expired with a future expires_at date' do
        @promo_code.update(expires_at: Time.now + 1.hour)
        expect(@promo_code).not_to be_expired
      end

      it 'should be expired with a past expires_at date' do
        @promo_code.update(expires_at: Time.now - 1.hour)
        expect(@promo_code).to be_expired
      end
    end

    describe 'usable' do
      it 'should be usable if active with a discount_type' do
        @promo_code.update(valid_at: Time.now - 1.hour, discount_type: 'member')
        expect(@promo_code).to be_usable
      end

      it 'should not be usable if not active' do
        @promo_code.update(valid_at: Time.now + 1.hour)
        expect(@promo_code).not_to be_usable
      end

      it 'should not be usable without a discount_type' do
        @promo_code.update(valid_at: Time.now + 1.hour)
        expect(@promo_code).not_to be_usable
      end
    end

    describe 'activatable' do
      it 'should be activatable if pending and with a discount_type' do
        @promo_code.update(valid_at: Time.now + 1.hour, discount_type: 'member')
        expect(@promo_code).to be_activatable
      end

      it 'should be activatable if expired and with a discount_type' do
        @promo_code.update(expires_at: Time.now - 1.hour, discount_type: 'member')
        expect(@promo_code).to be_activatable
      end

      it 'should not be activatable if active' do
        @promo_code.update(valid_at: Time.now - 1.hour)
        expect(@promo_code).not_to be_activatable
      end

      it 'should not be activatable without a discount_type' do
        expect(@promo_code).not_to be_activatable
      end
    end
  end

  it 'should correctly render the discount_display' do
    @promo_code.update(discount_type: 'percent', discount_amount: 5)
    expect(@promo_code.discount_display).to eql('5 %')
  end

  describe 'activate!' do
    it 'should correctly activate' do
      expect(@promo_code).not_to be_active
      @promo_code.activate!
      expect(@promo_code).to be_active
    end

    it 'should clear the expired flag if set' do
      @promo_code.expire!
      @promo_code.activate!
      expect(@promo_code).not_to be_expired
    end
  end

  it 'should correctly expire' do
    expect(@promo_code).not_to be_expired
    @promo_code.expire!
    expect(@promo_code).to be_expired
  end
end
