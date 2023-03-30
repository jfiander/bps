# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  before { generic_seo_and_ao }

  describe '.not_refunded' do
    let!(:normal) { create(:registration, :with_email) }
    let!(:refunded) do
      create(:registration, :with_email).tap { |r| r.payment.update(refunded: true) }
    end

    it 'includes only non-refunded registrations' do
      expect(described_class.not_refunded).to eq([normal])
    end
  end

  describe 'payable' do
    describe 'class.payable?' do
      it 'returns true for a payable class' do
        expect(described_class.payable?).to be(true)
      end

      it 'returns false for a non-payable class' do
        expect(HeaderImage.payable?).to be(false)
      end
    end

    describe 'instance.paid?' do
      it 'returns nil for a non-payable object' do
        expect(create(:static_page).paid?).to be_nil
      end

      it 'returns the paid flag for a payable object' do
        user = create(:user)
        reg = create(:event_registration, user: user)
        expect(reg.paid?).to eql(reg.payment.paid)
      end
    end

    context 'with a registration' do
      let(:event) { create(:event, cost: 15) }
      let(:reg) { create(:registration, event: event, user: user) }

      it 'returns the payable amount' do
        expect(reg.payment_amount).to be(15)
      end

      it 'returns the overridden payable amount' do
        reg.update(override_cost: 10)
        expect(reg.payment_amount).to be(10)
      end

      it 'detects if an object is payable' do
        expect(reg.payable?).to be(true)
      end

      it 'is not payable if advance_payment is required' do
        reg.event.update(advance_payment: true, cutoff_at: 1.hour.ago)
        expect(reg.payable?).to be(false)
      end

      it 'allows destroying an unpaid object' do
        expect { reg.destroy }.not_to raise_error
      end

      it 'does not allow destroying a paid object' do
        reg.payment.paid!('1234567890')
        expect { reg.destroy }.to raise_error(
          RuntimeError, 'This Registration has been paid, and cannot be destroyed.'
        )
      end
    end
  end

  describe '.obliterate_sql' do
    let(:event) { create(:event, cost: 5) }
    let!(:registration) { create(:registration, :with_email, event: event) }

    let(:start_at) { registration.created_at - 5.minutes }
    let(:end_at) { registration.created_at + 10.minutes }
    let(:start_at_str) { start_at.strftime('%Y-%m-%d %H:%M:%S') }
    let(:end_at_str) { end_at.strftime('%Y-%m-%d %H:%M:%S') }

    it 'generates the correct sql' do
      expect(described_class.obliterate_sql(start_at)).to eq(
        <<~SQL
          DELETE FROM registrations WHERE created_at > "#{start_at_str}" ;
          DELETE FROM payments WHERE parent_type = 'Registration' AND created_at > "#{start_at_str}" ;
          DELETE FROM versions WHERE item_type = 'Registration' AND created_at > "#{start_at_str}" ;
          DELETE FROM versions WHERE item_type = 'Payment' AND created_at > "#{start_at_str}" ;
        SQL
      )
    end

    it 'generates the correct sql with an end time' do
      expect(described_class.obliterate_sql(start_at, end_at)).to eq(
        <<~SQL
          DELETE FROM registrations WHERE created_at > "#{start_at_str}" AND created_at < "#{end_at_str}";
          DELETE FROM payments WHERE parent_type = 'Registration' AND created_at > "#{start_at_str}" AND created_at < "#{end_at_str}";
          DELETE FROM versions WHERE item_type = 'Registration' AND created_at > "#{start_at_str}" AND created_at < "#{end_at_str}";
          DELETE FROM versions WHERE item_type = 'Payment' AND created_at > "#{start_at_str}" AND created_at < "#{end_at_str}";
        SQL
      )
    end
  end

  describe '.obliterate!' do
    let(:event) { create(:event, cost: 5) }
    let!(:registration) { create(:registration, :with_email, event: event) }

    it 'removes the base records and associated records from the database', :aggregate_failures do
      described_class.obliterate!(5.minutes.ago)

      versions_count = ApplicationRecord.connection.execute('SELECT COUNT(*) FROM versions').first.first

      expect(versions_count).to eq(7)
      expect(Payment.count).to eq(0)
      expect(described_class.count).to eq(0)
    end

    it 'does not remove the record with just #destroy' do
      expect { registration.destroy }.not_to(
        change { described_class.unscoped.count }
      )
    end

    it 'does not remove associated records with just #destroy' do
      expect { registration.destroy }.not_to(
        change { Payment.unscoped.count }
      )
    end
  end

  it 'converts a public registration user email to user' do
    reg = create(:registration, email: user.email, event: event)
    expect(reg.user).to eql(user)
  end

  it 'is invalid without an email or user' do
    reg = build(:registration, event: event)
    expect(reg.valid?).to be(false)
    expect(reg.errors.messages.to_h).to eql(base: ['Must have a user or email'])
  end

  it 'is valid with an email' do
    reg = build(:registration, event: event, email: user.email)
    expect(reg.valid?).to be(true)
  end

  it 'is valid with a user' do
    reg = build(:registration, event: event, user: user)
    expect(reg.valid?).to be(true)
  end

  it 'does not allow duplicate registrations' do
    create(:registration, event: event, user: user)
    reg = build(:registration, event: event, user: user)
    expect(reg.valid?).to be(false)
    expect(reg.errors.messages.to_h).to eql(base: ['Duplicate'])
  end

  it 'notifies the chair of registrations' do
    create(:committee, user: generic_seo_and_ao[:ao].user, name: 'rendezvous')
    event_type = create(:event_type, event_category: 'meeting', title: 'rendezvous')
    event = create(:event, event_type: event_type)
    expect { create(:registration, user: user, event: event) }.not_to raise_error
  end

  it 'includes an attached PDF if present' do
    event.flyer = File.open(Rails.root.join('spec/Blank.pdf'), 'r')
    event.save
    reg = create(:registration, event: event, user: user)

    expect { RegistrationMailer.confirm(reg).deliver }.not_to raise_error
  end

  describe 'cost?' do
    it 'returns false without a cost' do
      reg = create(:registration, event: event, user: user)
      expect(reg.cost?).to be(false)
    end

    it 'returns true with a cost' do
      event.update(cost: 10)
      reg = create(:registration, event: event, user: user)
      expect(reg.cost?).to be(true)
    end
  end

  describe 'user?' do
    it 'returns false without a user' do
      reg = create(:registration, event: event, email: 'nobody@example.com')
      expect(reg.user?).to be(false)
    end

    it 'returns true with a user' do
      reg = create(:registration, event: event, user: user)
      expect(reg.user?).to be(true)
    end
  end

  describe 'type' do
    it 'returns course for public courses' do
      event_type = create(:event_type, event_category: 'public')
      event = create(:event, event_type: event_type)
      reg = create(:registration, event: event, user: user)
      expect(reg.type).to eql('course')
    end

    it 'returns course for advanced grade courses' do
      event_type = create(:event_type, event_category: 'advanced_grade')
      event = create(:event, event_type: event_type)
      reg = create(:registration, event: event, user: user)
      expect(reg.type).to eql('course')
    end

    it 'returns course for elective courses' do
      event_type = create(:event_type, event_category: 'elective')
      event = create(:event, event_type: event_type)
      reg = create(:registration, event: event, user: user)
      expect(reg.type).to eql('course')
    end

    it 'returns seminar for seminars' do
      event_type = create(:event_type, event_category: 'seminar')
      event = create(:event, event_type: event_type)
      reg = create(:registration, event: event, user: user)
      expect(reg.type).to eql('seminar')
    end

    it 'returns meeting for meetings' do
      event_type = create(:event_type, event_category: 'meeting')
      event = create(:event, event_type: event_type)
      reg = create(:registration, event: event, user: user)
      expect(reg.type).to eql('meeting')
    end
  end
end
