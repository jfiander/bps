# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromoCode do
  context 'with a single testing code' do
    let(:promo_code) { create(:promo_code, code: 'testing') }

    describe 'flags' do
      describe 'pending' do
        it 'is pending without a valid_at date' do
          expect(promo_code).to be_pending
        end

        it 'is pending with a future valid_at date' do
          promo_code.update(valid_at: 1.hour.from_now)
          expect(promo_code).to be_pending
        end

        it 'is not pending with a past valid_at date' do
          promo_code.update(valid_at: 1.hour.ago)
          expect(promo_code).not_to be_pending
        end
      end

      describe 'active' do
        it 'is active with a past valid_at date and no expires_at date' do
          promo_code.update(valid_at: 1.hour.ago)
          expect(promo_code).to be_active
        end

        it 'is active with a past valid_at date and future expires_at date' do
          promo_code.update(valid_at: 1.hour.ago, expires_at: 1.hour.from_now)
          expect(promo_code).to be_active
        end

        it 'is not active without a valid_at date' do
          expect(promo_code).not_to be_active
        end

        it 'is not active with a past expires_at date' do
          promo_code.update(expires_at: 1.hour.ago)
          expect(promo_code).not_to be_active
        end
      end

      describe 'expired' do
        it 'is not expired without an expires_at date' do
          expect(promo_code).not_to be_expired
        end

        it 'is not expired with a future expires_at date' do
          promo_code.update(expires_at: 1.hour.from_now)
          expect(promo_code).not_to be_expired
        end

        it 'is expired with a past expires_at date' do
          promo_code.update(expires_at: 1.hour.ago)
          expect(promo_code).to be_expired
        end
      end

      describe 'usable' do
        it 'is usable if active with a discount_type' do
          promo_code.update(valid_at: 1.hour.ago, discount_type: 'member')
          expect(promo_code).to be_usable
        end

        it 'is not usable if not active' do
          promo_code.update(valid_at: 1.hour.from_now)
          expect(promo_code).not_to be_usable
        end

        it 'is not usable without a discount_type' do
          promo_code.update(valid_at: 1.hour.ago)
          expect(promo_code).not_to be_usable
        end
      end

      describe 'activatable' do
        it 'is activatable if pending and with a discount_type' do
          promo_code.update(valid_at: 1.hour.from_now, discount_type: 'member')
          expect(promo_code).to be_activatable
        end

        it 'is activatable if expired and with a discount_type' do
          promo_code.update(expires_at: 1.hour.ago, discount_type: 'member')
          expect(promo_code).to be_activatable
        end

        it 'is not activatable if active' do
          promo_code.update(valid_at: 1.hour.ago)
          expect(promo_code).not_to be_activatable
        end

        it 'is not activatable without a discount_type' do
          expect(promo_code).not_to be_activatable
        end
      end
    end

    it 'correctly render the discount_display' do
      promo_code.update(discount_type: 'percent', discount_amount: 5)
      expect(promo_code.discount_display).to eql('5 %')
    end

    describe 'activate!' do
      it 'correctly activate' do
        expect(promo_code).not_to be_active
        promo_code.activate!
        expect(promo_code).to be_active
      end

      it 'clears the expired flag if set' do
        promo_code.expire!
        promo_code.activate!
        expect(promo_code).not_to be_expired
      end
    end

    it 'correctly expire' do
      expect(promo_code).not_to be_expired
      promo_code.expire!
      expect(promo_code).to be_expired
    end

    describe '#registrations' do
      before { generic_seo_and_ao }

      let!(:used) { create(:registration, :with_email).tap { |r| r.payment.update(promo_code: promo_code) } }
      let!(:other) { create(:registration, :with_email) }

      it 'returns registrations that use the promo code' do
        expect(promo_code.registrations).to eq([used])
      end
    end
  end

  describe 'scopes' do
    let!(:pending) { create(:promo_code, code: 'pending', valid_at: 1.hour.from_now) }
    let!(:current) { create(:promo_code, code: 'current', valid_at: 1.hour.ago) }
    let!(:expired) { create(:promo_code, code: 'expired', expires_at: 1.hour.ago) }

    it 'returns the list of current codes' do
      expect(described_class.current.to_a).to eql([current])
    end

    it 'returns the list of pending codes' do
      expect(described_class.pending.to_a).to eql([pending])
    end
  end
end
