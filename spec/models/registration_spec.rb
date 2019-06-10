# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @event = FactoryBot.create(:event)
    generic_seo_and_ao
  end

  describe 'payable' do
    describe 'class.payable?' do
      it 'returns true for a payable class' do
        expect(Registration.payable?).to be(true)
      end

      it 'returns false for a non-payable class' do
        expect(HeaderImage.payable?).to be(false)
      end
    end

    describe 'instance.paid?' do
      it 'returns nil for a non-payable object' do
        expect(FactoryBot.create(:static_page).paid?).to be(nil)
      end

      it 'returns the paid flag for a payable object' do
        user = FactoryBot.create(:user)
        reg = FactoryBot.create(:event_registration, user: user)
        expect(reg.paid?).to eql(reg.payment.paid)
      end
    end

    context 'with a registration' do
      before do
        user = FactoryBot.create(:user)
        event = FactoryBot.create(:event, cost: 15)
        @reg = FactoryBot.create(:registration, event: event, user: user)
      end

      it 'returns the payable amount' do
        expect(@reg.payment_amount).to be(15)
      end

      it 'returns the overridden payable amount' do
        @reg.update(override_cost: 10)
        expect(@reg.payment_amount).to be(10)
      end

      it 'detects if an object is payable' do
        expect(@reg.payable?).to be(true)
      end

      it 'is not payable if advance_payment is required' do
        @reg.event.update(advance_payment: true, cutoff_at: Time.now - 1.hour)
        expect(@reg.payable?).to be(false)
      end

      it 'allows destroying an unpaid object' do
        expect { @reg.destroy }.not_to raise_error
      end

      it 'does not allow destroying a paid object' do
        @reg.payment.paid!('1234567890')
        expect { @reg.destroy }.to raise_error(
          RuntimeError, 'This Registration has been paid, and cannot be destroyed.'
        )
      end
    end
  end

  it 'converts a public registration user email to user' do
    reg = FactoryBot.create(:registration, email: @user.email, event: @event)
    expect(reg.user).to eql(@user)
  end

  it 'requires an email or user' do
    reg = FactoryBot.build(:registration, event: @event)
    expect(reg.valid?).to be(false)
    expect(reg.errors.messages).to eql(base: ['Must have a user or event'])

    reg = FactoryBot.build(:registration, event: @event, email: @user.email)
    expect(reg.valid?).to be(true)

    reg = FactoryBot.build(:registration, event: @event, user: @user)
    expect(reg.valid?).to be(true)
  end

  it 'does not allow duplicate registrations' do
    FactoryBot.create(:registration, event: @event, user: @user)
    reg = FactoryBot.build(:registration, event: @event, user: @user)
    expect(reg.valid?).to be(false)
    expect(reg.errors.messages).to eql(base: ['Duplicate'])
  end

  it 'sends a confirmation email for public registrations' do
    expect { FactoryBot.create(:registration, email: 'nobody@example.com', event: @event) }.not_to raise_error
  end

  it 'notifies the chair of registrations' do
    FactoryBot.create(:committee, user: generic_seo_and_ao[:ao].user, name: 'rendezvous')
    event_type = FactoryBot.create(:event_type, event_category: 'meeting', title: 'rendezvous')
    event = FactoryBot.create(:event, event_type: event_type)
    expect { FactoryBot.create(:registration, user: @user, event: event) }.not_to raise_error
  end

  it 'includes an attached PDF if present' do
    @event.flyer = File.open(File.join(Rails.root, 'spec', 'Blank.pdf'), 'r')
    @event.save
    reg = FactoryBot.create(:registration, event: @event, user: @user)

    expect { RegistrationMailer.confirm(reg).deliver }.not_to raise_error
  end

  describe 'cost?' do
    it 'returns false without a cost' do
      reg = FactoryBot.create(:registration, event: @event, user: @user)
      expect(reg.cost?).to be(false)
    end

    it 'returns true with a cost' do
      @event.update(cost: 10)
      reg = FactoryBot.create(:registration, event: @event, user: @user)
      expect(reg.cost?).to be(true)
    end
  end

  describe 'user?' do
    it 'returns false without a user' do
      reg = FactoryBot.create(:registration, event: @event, email: 'nobody@example.com')
      expect(reg.user?).to be(false)
    end

    it 'returns true with a user' do
      reg = FactoryBot.create(:registration, event: @event, user: @user)
      expect(reg.user?).to be(true)
    end
  end

  describe 'type' do
    it 'returns course for public courses' do
      event_type = FactoryBot.create(:event_type, event_category: 'public')
      event = FactoryBot.create(:event, event_type: event_type)
      reg = FactoryBot.create(:registration, event: event, user: @user)
      expect(reg.type).to eql('course')
    end

    it 'returns course for advanced grade courses' do
      event_type = FactoryBot.create(:event_type, event_category: 'advanced_grade')
      event = FactoryBot.create(:event, event_type: event_type)
      reg = FactoryBot.create(:registration, event: event, user: @user)
      expect(reg.type).to eql('course')
    end

    it 'returns course for elective courses' do
      event_type = FactoryBot.create(:event_type, event_category: 'elective')
      event = FactoryBot.create(:event, event_type: event_type)
      reg = FactoryBot.create(:registration, event: event, user: @user)
      expect(reg.type).to eql('course')
    end

    it 'returns seminar for seminars' do
      event_type = FactoryBot.create(:event_type, event_category: 'seminar')
      event = FactoryBot.create(:event, event_type: event_type)
      reg = FactoryBot.create(:registration, event: event, user: @user)
      expect(reg.type).to eql('seminar')
    end

    it 'returns meeting for meetings' do
      event_type = FactoryBot.create(:event_type, event_category: 'meeting')
      event = FactoryBot.create(:event, event_type: event_type)
      reg = FactoryBot.create(:registration, event: event, user: @user)
      expect(reg.type).to eql('meeting')
    end
  end
end
