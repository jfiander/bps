# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  before(:each) { generic_seo_and_ao }

  describe 'scopes' do
    it 'should filter by category' do
      seminar_type = FactoryBot.create(:event_type, event_category: 'seminar')
      course_type = FactoryBot.create(:event_type, event_category: 'public')
      seminar = FactoryBot.create(:event, event_type: seminar_type)
      FactoryBot.create(:event, event_type: course_type)
      expect(Event.for_category('seminar').to_a).to eql([seminar])
    end

    it 'should filter by current' do
      event_type = FactoryBot.create(:event_type, event_category: 'seminar')
      FactoryBot.create_list(:event, 2, event_type: event_type)
      FactoryBot.create(:event, event_type: event_type, expires_at: Time.now)
      expect(Event.current('seminar').to_a).to eql(Event.first(2))
    end

    it 'should filter by expired' do
      event_type = FactoryBot.create(:event_type, event_category: 'seminar')
      FactoryBot.create_list(:event, 2, event_type: event_type)
      FactoryBot.create(:event, event_type: event_type, expires_at: Time.now)
      expect(Event.expired('seminar').to_a).to eql([Event.last])
    end

    it 'should filter with registrations' do
      FactoryBot.create_list(:event, 2)
      user = FactoryBot.create(:user)
      event = Event.last
      FactoryBot.create(:registration, event: event, user: user)
      expect(Event.with_registrations.to_a).to eql([event])
    end
  end

  describe 'types' do
    it 'should create a course' do
      event_type = FactoryBot.create(:event_type, event_category: 'public')
      event = FactoryBot.create(:event, event_type: event_type)
      expect { event }.not_to raise_error
    end

    it 'should create a seminar' do
      event_type = FactoryBot.create(:event_type, event_category: 'seminar')
      event = FactoryBot.create(:event, event_type: event_type)
      expect { event }.not_to raise_error
    end

    it 'should create a meeting' do
      event_type = FactoryBot.create(:event_type, event_category: 'meeting')
      event = FactoryBot.create(:event, event_type: event_type)
      expect { event }.not_to raise_error
    end
  end

  context 'with event factory' do
    before(:each) do
      @event = FactoryBot.create(:event)
    end

    describe 'destroy' do
      it 'should destroy an event' do
        expect { @event.destroy }.not_to raise_error
      end
    end

    describe 'flags' do
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

      describe 'reminding' do
        it 'should set the reminded flag after sending reminders' do
          expect(@event.reminded?).to be(false)
          expect(@event.remind!).to be(true)
          expect(@event.reminded?).to be(true)
        end

        it 'should not allow duplicate reminders' do
          expect(@event.remind!).to be(true)
          expect(@event.remind!).to be(nil)
        end
      end

      describe 'booked' do
        it 'should set the booked flag after booking' do
          @event.unbook!
          expect(@event.booked?).to be(false)
          expect(@event.book!).to be(true)
          expect(@event.booked?).to be(true)
        end

        it 'should unset the booked flag after unbooking' do
          expect(@event.booked?).to be(true)
          expect(@event.unbook!).to be(true)
          expect(@event.booked?).to be(false)
        end
      end

      describe 'calendar API silent failures' do
        before(:each) do
          allow(@event).to(receive(:calendar).and_raise('An error'))
        end

        it 'should not allow errors to surface from book!' do
          @event.update(google_calendar_event_id: nil)
          expect { @event.book! }.not_to raise_error
        end

        it 'should not allow errors to surface from unbook!' do
          @event.book!
          expect { @event.unbook! }.not_to raise_error
        end

        it 'should not allow errors to surface from refresh_calendar!' do
          @event.book!
          expect { @event.refresh_calendar! }.not_to raise_error
        end
      end

      describe 'within a week' do
        it 'should return false if the start date is more than 1 week away' do
          @event.start_at = Time.now + 2.weeks
          expect(@event.within_a_week?).to be(false)
        end

        it 'should return true if the start date is less than 1 week away' do
          @event.start_at = Time.now + 3.days
          expect(@event.within_a_week?).to be(true)
        end
      end

      describe 'category' do
        it 'should return the category group of the event_type' do
          expect(@event.category).to eql('course')
        end

        it 'should return true for the correct category' do
          expect(@event.course?).to be(true)
        end

        it 'should return false for all other categories' do
          expect(@event.seminar?).to be(false)
          expect(@event.meeting?).to be(false)
        end

        it 'should check the category from cache' do
          FactoryBot.create(:event_type, event_category: 'public')
          FactoryBot.create(:event_type, event_category: 'seminar')
          FactoryBot.create(:event_type, event_category: 'meeting')
          event_types = EventType.all

          expect(@event.category(event_types)).to eql('course')
        end
      end

      describe 'scheduling' do
        let(:zero_time) { Time.now.beginning_of_day } # .strptime('%-kh %Mm')

        describe 'length' do
          it 'should return false when blank' do
            @event.length = nil
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
          expect(@event.usps_cost).to be_nil
          expect(@event.member_cost).to be_nil
        end

        it 'should reject member_cost when no cost is specified' do
          @event.update(member_cost: 16)
          expect(@event.cost).to be_nil
          expect(@event.usps_cost).to be_nil
          expect(@event.member_cost).to be_nil
        end

        it 'should reject usps_cost when no cost is specified' do
          @event.update(usps_cost: 11)
          expect(@event.cost).to be_nil
          expect(@event.usps_cost).to be_nil
          expect(@event.member_cost).to be_nil
        end

        it 'should store the member_cost and cost correctly when backwards' do
          @event.update(cost: 17, member_cost: 20)
          expect(@event.cost).to eql(20)
          expect(@event.usps_cost).to be_nil
          expect(@event.member_cost).to eql(17)
        end

        it 'should store both costs when valid' do
          @event.update(cost: 18, member_cost: 12)
          expect(@event.cost).to eql(18)
          expect(@event.usps_cost).to be_nil
          expect(@event.member_cost).to eql(12)
        end

        it 'should reject usps_cost when below range' do
          @event.update(cost: 20, usps_cost: 12, member_cost: 15)
          expect(@event.member_cost).to eql(15)
          expect(@event.usps_cost).to be_nil
          expect(@event.cost).to eql(20)
        end

        it 'should reject usps_cost when above range' do
          @event.update(cost: 21, usps_cost: 24, member_cost: 13)
          expect(@event.member_cost).to eql(13)
          expect(@event.usps_cost).to be_nil
          expect(@event.cost).to eql(21)
        end

        it 'should store all costs when valid' do
          @event.update(cost: 18, usps_cost: 16, member_cost: 12)
          expect(@event.cost).to eql(18)
          expect(@event.usps_cost).to eql(16)
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
            '<b>Cost:</b>&nbsp;$10'
          )
        end

        it 'should correctly format both costs' do
          @event.update(cost: 10, member_cost: 5)
          expect(@event.formatted_cost).to eql(
            '<b>Members:</b>&nbsp;$5, <b>Non-members:</b>&nbsp;$10'
          )
        end

        it 'should correctly format a nil length' do
          @event.length = nil
          expect(@event.formatted_length).to be_nil
        end

        it 'should correctly format a whole-hour length' do
          @event.length = Time.now.beginning_of_day + 1.hour
          @event.save

          expect(@event.formatted_length).to eql('1 hour')
        end

        it 'should correctly format a length with minutes' do
          @event.length = Time.now.beginning_of_day + 2.hours + 15.minutes
          @event.save

          expect(@event.formatted_length).to eql('2 hours 15 mins')
        end
      end
    end

    describe 'flyers' do
      it 'should get the correct course book cover' do
        event_type = FactoryBot.create(:event_type, event_category: 'public')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.get_flyer).to eql(
          'https://static.bpsd9.org/book_covers/courses/americas_boating_course.jpg'
        )
      end

      it 'should get the correct seminar book cover' do
        event_type = FactoryBot.create(:event_type, event_category: 'seminar', title: 'vhf_dsc')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.get_flyer).to eql(
          'https://static.bpsd9.org/book_covers/seminars/vhf_dsc.jpg'
        )
      end

      it 'should check if the event has a flyer' do
        event_type = FactoryBot.create(:event_type, event_category: 'meeting')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.get_flyer).to be_nil
      end

      it 'should generate the correct flyer link' do
        event_type = FactoryBot.create(:event_type, event_category: 'meeting')
        flyer = File.open(test_image(250, 500), 'r')
        event = FactoryBot.create(:event, event_type: event_type, flyer: flyer)
        expect(event.get_flyer).to match(
          %r{https://files.development.bpsd9.org/event_flyers/#{event.id}/test_image.jpg\?[^ ]*?}
        )
      end
    end
  end

  describe 'calendar ids' do
    it 'should use the test calendar when not in production' do
      event_type = FactoryBot.create(:event_type, event_category: 'public')
      event = FactoryBot.create(:event, event_type: event_type)
      expect(event.send(:calendar_id)).to eql(
        ENV['GOOGLE_CALENDAR_ID_TEST']
      )
    end

    context 'production' do
      it 'should use the education calendar for courses' do
        event_type = FactoryBot.create(:event_type, event_category: 'public')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.send(:calendar_id, production: true)).to eql(
          ENV['GOOGLE_CALENDAR_ID_EDUC']
        )
      end

      it 'should use the education calendar for seminars' do
        event_type = FactoryBot.create(:event_type, event_category: 'seminar')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.send(:calendar_id, production: true)).to eql(
          ENV['GOOGLE_CALENDAR_ID_EDUC']
        )
      end

      it 'should use the education calendar for meetings' do
        event_type = FactoryBot.create(:event_type, event_category: 'meeting')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.send(:calendar_id, production: true)).to eql(
          ENV['GOOGLE_CALENDAR_ID_GEN']
        )
      end
    end
  end

  describe 'all day' do
    it 'should create a valid event with the all_day flag set' do
      expect { FactoryBot.create(:event, all_day: true) }.not_to raise_error
    end
  end

  describe 'display_title' do
    it 'should use the event_type display_title without a summary' do
      event_type = FactoryBot.create(:event_type)
      event = FactoryBot.create(:event, event_type: event_type)
      expect(event.display_title).to eql(event_type.display_title)
    end

    it 'should use the summary when present' do
      event_type = FactoryBot.create(:event_type)
      event = FactoryBot.create(:event, event_type: event_type, summary: 'Name')
      expect(event.display_title).to eql('Name')
    end
  end
end
