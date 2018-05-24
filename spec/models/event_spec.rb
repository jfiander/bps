# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  before(:each) do
    @event = FactoryBot.create(:event)
  end

  describe 'flags' do
    describe 'event_type' do
      it 'should return the category group of the event_type' do
        expect(@event.category).to eql(:course)
      end
    end

    describe 'expiration' do
      it 'should return true when expired' do
        @event.update(expires_at: Time.now - 1.day)
        expect(@event.expired?).to be(true)
      end

      it 'should return false when not expired' do
        @event.update(expires_at: Time.now + 1.day)
        expect(@event.expired?).to be(false)
      end
    end

    describe 'cutoff' do
      it 'should return true when not accepting registrations' do
        @event.update(cutoff_at: Time.now - 1.day)
        expect(@event.cutoff?).to be(true)
      end

      it 'should return false when accepting registrations' do
        @event.update(cutoff_at: Time.now + 1.day)
        expect(@event.cutoff?).to be(false)
      end
    end

    describe 'category' do
      it 'should return true for the correct category' do
        expect(@event.course?).to be(true)
      end

      it 'should return false for all other categories' do
        expect(@event.seminar?).to be(false)
        expect(@event.meeting?).to be(false)
      end
    end

    describe 'scheduling' do
      let(:zero_time) { Time.now.beginning_of_day } # .strptime('%-kh %Mm')

      describe 'length' do
        it 'should return false when blank' do
          expect(@event.length?).to be(false)
        end

        it 'should return false when zero length' do
          @event.update(length: zero_time)
          expect(@event.length?).to be(false)
        end

        it 'should return true when a valid length is set' do
          @event.update(length: zero_time + 2.hours)
          expect(@event.length?).to be(true)
        end
      end

      describe 'multiple sessions' do
        it 'should return false if sessions is blank' do
          expect(@event.multiple_sessions?).to be(false)
        end

        it 'should return false if only one session' do
          @event.update(sessions: 1)
          expect(@event.multiple_sessions?).to be(false)
        end

        it 'should return true if more than one session' do
          @event.update(sessions: 2)
          expect(@event.multiple_sessions?).to be(true)
        end
      end
    end

    describe 'registerable' do
      it 'should return true if neither cutoff not expiration are set' do
        expect(@event.registerable?).to be(true)
      end

      it 'should return false if cutoff date is past' do
        @event.update(cutoff_at: Time.now - 1.day)
        expect(@event.registerable?).to be(false)
      end

      it 'should return false if expiration date is past' do
        @event.update(expires_at: Time.now - 1.day)
        expect(@event.registerable?).to be(false)
      end

      it 'should return true if both cutoff not expiration are future' do
        @event.update(cutoff_at: Time.now + 1.days, expires_at: Time.now + 2.days)
        expect(@event.registerable?).to be(true)
      end
    end
  end

  describe 'registration' do
    it 'should correctly register a user' do
      user = FactoryBot.create(:user)
      event = FactoryBot.create(:event)

      expect(Registration.where(event: event, user: user)).to be_blank
      event.register_user(user)
      expect(Registration.where(event: event, user: user)).not_to be_blank
    end
  end

  describe 'validations' do
    describe 'costs' do
      it 'should store only the cost' do
        @event.update(cost: 15)
        expect(@event.cost).to eql(15)
        expect(@event.member_cost).to be_nil
      end

      it 'should store member_cost as cost when no cost is specified' do
        @event.update(member_cost: 16)
        expect(@event.cost).to eql(16)
        expect(@event.member_cost).to be_nil
      end

      it 'should store only the member_cost as cost when higher than cost' do
        @event.update(cost: 17, member_cost: 20)
        expect(@event.cost).to eql(20)
        expect(@event.member_cost).to be_nil
      end

      it 'should store both costs when valid' do
        @event.update(cost: 18, member_cost: 12)
        expect(@event.cost).to eql(18)
        expect(@event.member_cost).to eql(12)
      end
    end
  end

  describe 'formatting' do
    describe 'costs' do
      it 'should return nil if there are no costs' do
        expect(@event.formatted_cost).to be_nil
      end

      it 'should correctly format a single cost' do
        @event.update(cost: 10)
        expect(@event.formatted_cost).to eql(
          '<b>Cost:</b> $10'
        )
      end

      it 'should correctly format both costs' do
        @event.update(cost: 10, member_cost: 5)
        expect(@event.formatted_cost).to eql(
          '<b>Members:</b> $5, <b>Non-members:</b> $10'
        )
      end
    end
  end
end
