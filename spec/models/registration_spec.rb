# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @event = FactoryBot.create(:event)
    generic_seo_and_ao
  end

  describe 'scopes' do
    before do
      @expired, = register(FactoryBot.create(:event, expires_at: 1.week.ago))
      @current, = register(FactoryBot.create(:event, expires_at: Time.zone.now + 1.week))
    end

    it 'current' do
      expect(Registration.current.to_a).to eql([@current])
    end

    it 'expired' do
      expect(Registration.expired.to_a).to eql([@expired])
    end
  end

  it 'adds an additional person to a registration' do
    reg = register(email: 'test@example.com').first
    email = reg.user_registrations.first.email
    reg.add(email: 'someone_else@example.com')

    expect(reg.user_registrations.map(&:email)).to eql([email, 'someone_else@example.com'])
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
        reg = register.first
        expect(reg.paid?).to eql(reg.payment.paid)
      end
    end

    context 'with a registration' do
      before do
        event = FactoryBot.create(:event, cost: 15)
        @reg = register(event).first
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
        @reg.event.update(advance_payment: true, cutoff_at: Time.zone.now - 1.hour)
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
    reg = register(email: @user.email).first
    expect(reg.user).to eql(@user)
  end

  it 'requires an email or user' do
    reg = FactoryBot.build(:registration, event: @event)
    expect(reg.valid?).to be(false)
    expect(reg.errors.messages).to eql(user_registrations: ["can't be blank"])

    reg = register(email: 'something@example.com', save: false).first
    expect(reg.save!).to be(true)

    reg = register(user: FactoryBot.create(:user), save: false).first
    expect(reg.save!).to be(true)
  end

  it 'does not raise an error for public registrations' do
    expect { register(email: 'test@example.com') }.not_to raise_error
  end

  it 'does not raise an error from sending rendezvous new registration email' do
    expect do
      reg = register(event_for_category('meeting', title: 'rendezvous').first).first
      reg.notify_new
    end.not_to raise_error
  end

  it 'does not raise an error from sending rendezvous confirmation emails' do
    expect do
      reg = register(event_for_category('meeting', title: 'rendezvous').first).first
      reg.confirm_to_registrants
    end.not_to raise_error
  end

  it 'notifies the chair of registrations' do
    FactoryBot.create(:committee, user: generic_seo_and_ao[:ao].user, name: 'rendezvous')
    event = event_for_category('meeting', title: 'rendezvous').first
    expect { register(event) }.not_to raise_error
  end

  it 'includes an attached PDF if present' do
    @event.flyer = File.open(Rails.root.join('spec', 'Blank.pdf'), 'r')
    @event.save
    reg = register(@event).first

    expect { RegistrationMailer.confirm(reg).deliver }.not_to raise_error
  end

  describe 'cost?' do
    it 'returns false without a cost' do
      reg = register(@event).first
      expect(reg.cost?).to be(false)
    end

    it 'returns true with a cost' do
      @event.update(cost: 10)
      reg = register(@event).first
      expect(reg.cost?).to be(true)
    end
  end

  describe 'user?' do
    it 'returns false without a user' do
      reg = register(email: 'test@example.com').first
      expect(reg.user?).to be(false)
    end

    it 'returns true with a user' do
      reg = register.first
      expect(reg.user?).to be(true)
    end
  end

  describe 'type' do
    it 'returns course for public courses' do
      event = event_for_category('public').first
      reg = register(event).first
      expect(reg.type).to eql('course')
    end

    it 'returns course for advanced grade courses' do
      event = event_for_category('advanced_grade').first
      reg = register(event).first
      expect(reg.type).to eql('course')
    end

    it 'returns course for elective courses' do
      event = event_for_category('elective').first
      reg = register(event).first
      expect(reg.type).to eql('course')
    end

    it 'returns seminar for seminars' do
      event = event_for_category('seminar').first
      reg = register(event).first
      expect(reg.type).to eql('seminar')
    end

    it 'returns meeting for meetings' do
      event = event_for_category('meeting').first
      reg = register(event).first
      expect(reg.type).to eql('meeting')
    end
  end

  it 'raises an error if no event is specified' do
    expect { Registration.register(user: FactoryBot.create(:user)) }.to raise_error(
      ArgumentError, 'Must specify an event or event_id'
    )
  end

  it 'returns registrations for a specified user' do
    user = FactoryBot.create(:user)
    event = FactoryBot.create(:event)
    reg = user.register_for(event)
    FactoryBot.create(:user).register_for(event)

    expect(Registration.for_user(user).to_a).to eql([reg])
  end
end
