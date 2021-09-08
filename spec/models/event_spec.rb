# frozen_string_literal: true

require 'rails_helper'

# def event_it(description, &block)
#   it(description, &block)
# rescue Google::Apis::RateLimitError
#   print('s')
#   skip 'Exceeded rate limit. Skipping spec.'
# end

RSpec.describe Event, type: :model, slow: true do
  before { generic_seo_and_ao }

  describe 'scopes' do
    it 'filters by category' do
      seminar_type = FactoryBot.create(:event_type, event_category: 'seminar')
      course_type = FactoryBot.create(:event_type, event_category: 'public')
      seminar = FactoryBot.create(:event, event_type: seminar_type)
      FactoryBot.create(:event, event_type: course_type)
      expect(described_class.for_category('seminar').to_a).to eql([seminar])
    end

    it 'filters by current' do
      event_type = FactoryBot.create(:event_type, event_category: 'seminar')
      FactoryBot.create_list(:event, 2, event_type: event_type)
      FactoryBot.create(:event, event_type: event_type, expires_at: Time.zone.now)
      expect(described_class.current.for_category('seminar').to_a).to eql(described_class.first(2))
    end

    it 'filters by expired' do
      event_type = FactoryBot.create(:event_type, event_category: 'seminar')
      FactoryBot.create_list(:event, 2, event_type: event_type)
      FactoryBot.create(:event, event_type: event_type, expires_at: Time.zone.now)
      expect(described_class.expired.for_category('seminar').to_a).to eql([described_class.last])
    end

    it 'filters with registrations' do
      FactoryBot.create_list(:event, 2)
      user = FactoryBot.create(:user)
      event = described_class.last
      FactoryBot.create(:registration, event: event, user: user)
      expect(described_class.with_registrations.to_a).to eql([event])
    end
  end

  describe 'types' do
    it 'creates a course' do
      event_type = FactoryBot.create(:event_type, event_category: 'public')
      event = FactoryBot.create(:event, event_type: event_type)
      expect { event }.not_to raise_error
    end

    it 'creates a seminar' do
      event_type = FactoryBot.create(:event_type, event_category: 'seminar')
      event = FactoryBot.create(:event, event_type: event_type)
      expect { event }.not_to raise_error
    end

    it 'creates a meeting' do
      event_type = FactoryBot.create(:event_type, event_category: 'meeting')
      event = FactoryBot.create(:event, event_type: event_type)
      expect { event }.not_to raise_error
    end
  end

  context 'with event factory' do
    let(:event) { FactoryBot.create(:event) }

    describe 'destroy' do
      it 'destroys an event' do
        expect { event.destroy }.not_to raise_error
      end
    end

    describe 'flags' do
      describe 'expiration' do
        it 'returns true when expired' do
          event.update(expires_at: Time.zone.now - 1.day)
          expect(event.expired?).to be(true)
        end

        it 'returns false when not expired' do
          event.update(expires_at: Time.zone.now + 1.day)
          expect(event.expired?).to be(false)
        end
      end

      describe 'archival' do
        it 'returns true when archived' do
          event.update(archived_at: Time.zone.now - 1.day)
          expect(event.archived?).to be(true)
        end

        it 'returns false when not archived' do
          event.update(archived_at: Time.zone.now + 1.day)
          expect(event.archived?).to be(false)
        end
      end

      describe 'cutoff' do
        it 'returns true when not accepting registrations' do
          event.update(cutoff_at: Time.zone.now - 1.day)
          expect(event.cutoff?).to be(true)
        end

        it 'returns false when accepting registrations' do
          event.update(cutoff_at: Time.zone.now + 1.day)
          expect(event.cutoff?).to be(false)
        end
      end

      describe 'reminding' do
        it 'sets the reminded flag after sending reminders' do
          expect { event.remind! }.to change { event.reminded? }.from(false).to(true)
        end

        it 'does not allow duplicate reminders' do
          expect(event.remind!).to be(true)
          expect(event.remind!).to be(nil)
        end
      end

      describe 'hiding old events' do
        it 'expires the event' do
          expect(event.expires_at).to be > Time.zone.now
          event.expire!
          expect(event.expires_at).to be < Time.zone.now
        end

        it 'archives the event' do
          expect(event.archived_at).to be_nil
          event.archive!
          expect(event.archived_at).to be < Time.zone.now
        end
      end

      describe 'booked' do
        it 'sets the booked flag after booking' do
          event.unbook!
          expect { event.book! }.to change { event.booked? }.from(false).to(true)
        end

        it 'unsets the booked flag after unbooking' do
          expect { event.unbook! }.to change { event.booked? }.from(true).to(false)
        end
      end

      describe 'refresh_calendar!' do
        let(:calendar) { event.send(:calendar) }

        before { allow(calendar).to receive(:update) }

        it 'skips if expired', :aggregate_failures do
          event.expires_at = Time.now - 1.day

          expect(calendar).not_to receive(:update)
          expect(event.refresh_calendar!).to eq(true)
        end

        it 'skips if archived', :aggregate_failures do
          event.archived_at = Time.now - 1.day

          expect(calendar).not_to receive(:update)
          expect(event.refresh_calendar!).to eq(true)
        end

        it 'attempts to book the event if not already' do
          allow(event).to receive(:booked?).and_return(false)
          allow(event).to receive(:book!)

          expect(event).to receive(:book!)

          event.refresh_calendar!
        end

        it 'updates the calendar' do
          allow(event).to receive(:conference!)

          expect(calendar).to receive(:update)

          event.refresh_calendar!
        end
      end

      describe 'recurrence' do
        it 'sets the correct pattern' do
          event_type = FactoryBot.create(:event_type, event_category: 'seminar')
          event = FactoryBot.create(:event, event_type: event_type, sessions: 2, all_day: false)
          expect(event.send(:recurrence)).to eq(['RRULE:FREQ=WEEKLY;COUNT=2'])
        end

        it 'returns nil for all_day events' do
          event_type = FactoryBot.create(:event_type, event_category: 'seminar')
          event = FactoryBot.create(:event, event_type: event_type, sessions: 2, all_day: true)
          expect(event.send(:recurrence)).to be_nil
        end

        it 'returns nil for individual events' do
          event_type = FactoryBot.create(:event_type, event_category: 'seminar')
          event = FactoryBot.create(:event, event_type: event_type, sessions: 1, all_day: false)
          expect(event.send(:recurrence)).to be_nil
        end
      end

      describe 'calendar event not found silent error' do
        before do
          allow(event).to(receive(:calendar).and_raise(Google::Apis::ClientError, 'notFound: Not Found'))
        end

        it 'returns false if an event is not found' do
          event.update(google_calendar_event_id: 'nonexistent-event-id')
          expect(event.on_calendar?).to be(false)
        end
      end

      describe 'calendar API silent failures' do
        before { allow(event).to(receive(:calendar).and_raise('An error')) }

        it 'does not allow errors to surface from book!' do
          event.update(google_calendar_event_id: nil)
          expect { event.book! }.not_to raise_error
        end

        it 'does not allow errors to surface from unbook!' do
          event.book!
          expect { event.unbook! }.not_to raise_error
        end

        it 'does not allow errors to surface from refresh_calendar!' do
          event.book!
          expect { event.refresh_calendar! }.not_to raise_error
        end
      end

      describe 'conference data' do
        before { event.book! }

        # it 'returns nil when conference data is not available' do
        #   skip 'Disabled for mock'
        #   expect(event.conference_id).to be(nil)
        # end

        it 'returns nil when calendar event does have conference info' do
          allow(event).to receive(:conference_id_cache).and_return(nil)
          allow(event.send(:calendar)).to receive(:conference_info).and_raise(
            Google::Apis::ClientError, 'notFound: Not Found'
          )

          expect(event.conference_id).to eq(nil)
        end

        context 'with conference specified' do
          before { event.conference! }

          it 'sets conference data correctly' do
            expect(event.online).to be(true)
            expect(event.conference_id).not_to be(nil)
          end

          it 'clears conference data correctly' do
            event.conference!(state: false)

            expect(event.online).to be(false)
            # expect(event.conference_id).to be(nil) # Disabled for mock
          end

          it 'sets the conference_id correctly' do
            expect(event.conference_id).to match(/[a-z]{3}-[a-z]{4}-[a-z]{3}/)
          end

          it 'returns a valid conference_link' do
            expect(event.conference_link).to match(%r(http://meet\.google\.com/[a-z]{3}-[a-z]{4}-[a-z]{3}))
          end
        end
      end

      describe 'within a week' do
        it 'returns false if the start date is more than 1 week away' do
          event.start_at = Time.zone.now + 2.weeks
          expect(event.within_a_week?).to be(false)
        end

        it 'returns true if the start date is less than 1 week away' do
          event.start_at = Time.zone.now + 3.days
          expect(event.within_a_week?).to be(true)
        end
      end

      describe 'category' do
        it 'returns the category group of the event_type' do
          expect(event.category).to eql('course')
        end

        it 'returns true for the correct category' do
          expect(event.course?).to be(true)
        end

        it 'returns false for all other categories' do
          expect(event.seminar?).to be(false)
          expect(event.meeting?).to be(false)
        end
      end

      describe 'scheduling' do
        describe 'length' do
          it 'returns false when blank' do
            event.update(length_h: nil)
            expect(event.length?).to be(false)
          end

          it 'returns false when zero length' do
            event.update(length_h: 0)
            expect(event.length?).to be(false)
          end

          it 'returns true when a valid length is set' do
            event.update(length_h: 2)
            expect(event.length?).to be(true)
          end
        end

        describe 'multiple sessions' do
          it 'returns false if sessions is blank' do
            expect(event.multiple_sessions?).to be(false)
          end

          it 'returns false if only one session' do
            event.update(sessions: 1)
            expect(event.multiple_sessions?).to be(false)
          end

          it 'returns true if more than one session' do
            event.update(sessions: 2)
            expect(event.multiple_sessions?).to be(true)
          end
        end
      end

      describe 'registerable' do
        it 'returns true if neither cutoff not expiration are set' do
          expect(event.registerable?).to be(true)
        end

        it 'returns false if cutoff date is past' do
          event.update(cutoff_at: Time.zone.now - 1.day)
          expect(event.registerable?).to be(false)
        end

        it 'returns true if only expiration date is past' do
          event.update(expires_at: Time.zone.now - 1.day)
          expect(event.registerable?).to be(true)
        end

        it 'returns false if expiration date and start date are past' do
          event.update(expires_at: Time.zone.now - 1.day, start_at: Time.zone.now - 2.days)
          expect(event.registerable?).to be(false)
        end

        it 'returns true if both cutoff not expiration are future' do
          event.update(cutoff_at: Time.zone.now + 1.day, expires_at: Time.zone.now + 2.days)
          expect(event.registerable?).to be(true)
        end
      end
    end

    describe 'registration' do
      it 'correctlies register a user' do
        user = FactoryBot.create(:user)
        event = FactoryBot.create(:event)

        expect(Registration.where(event: event, user: user)).to be_blank
        event.register_user(user)
        expect(Registration.where(event: event, user: user)).not_to be_blank
      end
    end

    describe 'with_instructor' do
      it 'works with instructors' do
        event = FactoryBot.create(:event, :with_instructor)

        expect(event).to be_valid
      end
    end

    describe 'validations' do
      describe 'costs' do
        it 'stores only the cost' do
          event.update(cost: 15)

          expect(event).to have_attributes(cost: 15, usps_cost: nil, member_cost: nil)
        end

        it 'rejects member_cost when no cost is specified' do
          event.update(member_cost: 16)

          expect(event).to have_attributes(cost: nil, usps_cost: nil, member_cost: nil)
        end

        it 'rejects usps_cost when no cost is specified' do
          event.update(usps_cost: 11)

          expect(event).to have_attributes(cost: nil, usps_cost: nil, member_cost: nil)
        end

        it 'stores the member_cost and cost correctly when backwards' do
          event.update(cost: 17, member_cost: 20)

          expect(event).to have_attributes(cost: 20, usps_cost: nil, member_cost: 17)
        end

        it 'stores both costs when valid' do
          event.update(cost: 18, member_cost: 12)

          expect(event).to have_attributes(cost: 18, usps_cost: nil, member_cost: 12)
        end

        it 'rejects member_cost when equal to cost' do
          event.update(cost: 15, member_cost: 15)

          expect(event).to have_attributes(cost: 15, usps_cost: nil, member_cost: nil)
        end

        it 'rejects usps_cost when below range' do
          event.update(cost: 20, usps_cost: 12, member_cost: 15)

          expect(event).to have_attributes(cost: 20, usps_cost: nil, member_cost: 15)
        end

        it 'rejects usps_cost when equal to range boundary' do
          event.update(cost: 19, usps_cost: 14, member_cost: 14)

          expect(event).to have_attributes(cost: 19, usps_cost: nil, member_cost: 14)
        end

        it 'rejects usps_cost when above range' do
          event.update(cost: 21, usps_cost: 24, member_cost: 13)

          expect(event).to have_attributes(cost: 21, usps_cost: nil, member_cost: 13)
        end

        it 'stores all costs when valid' do
          event.update(cost: 18, usps_cost: 16, member_cost: 12)

          expect(event).to have_attributes(cost: 18, usps_cost: 16, member_cost: 12)
        end

        describe '#needs_advance_payment?' do
          before { event.update(cost: 5, advance_payment: true) }

          it 'returns true when advance payment is needed' do
            expect(event.needs_advance_payment?).to be(true)
          end

          it 'returns false without a cost' do
            event.update(cost: 0)

            expect(event.needs_advance_payment?).to be(false)
          end

          it 'returns false when advance payment is disabled' do
            event.update(advance_payment: false)

            expect(event.needs_advance_payment?).to be(false)
          end
        end
      end
    end

    describe 'formatting' do
      describe 'length' do
        it 'correctly formats a nil length' do
          event.update(length_h: nil)
          expect(event.formatted_length).to be_nil
        end

        it 'correctly formats a whole-hour length' do
          event.update(length_h: 1)

          expect(event.formatted_length).to eql('1 hour')
        end

        it 'correctly formats a length with minutes' do
          event.update(length_h: 2, length_m: 15)

          expect(event.formatted_length).to eql('2 hours 15 mins')
        end
      end
    end

    describe 'flyers' do
      it 'gets the correct course book cover' do
        event_type = FactoryBot.create(:event_type, event_category: 'public')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.pick_flyer).to eql('https://static.bpsd9.org/book_covers/courses/americas_boating_course.jpg')
      end

      it 'gets the correct seminar book cover' do
        event_type = FactoryBot.create(:event_type, event_category: 'seminar', title: 'vhf_dsc')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.pick_flyer).to eql('https://static.bpsd9.org/book_covers/seminars/vhf_dsc.jpg')
      end

      it 'checks if the event has a flyer' do
        event_type = FactoryBot.create(:event_type, event_category: 'meeting')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.pick_flyer).to be_nil
      end

      it 'generates the correct flyer link' do
        event_type = FactoryBot.create(:event_type, event_category: 'meeting')
        flyer = File.open(test_image(250, 500), 'r')
        event = FactoryBot.create(:event, event_type: event_type, flyer: flyer)
        expect(event.pick_flyer).to match(
          %r{https://files.development.bpsd9.org/event_flyers/#{event.id}/test_image.jpg\?[^ ]*?}
        )
      end
    end
  end

  describe 'calendar ids' do
    it 'uses the test calendar when not in production' do
      event_type = FactoryBot.create(:event_type, event_category: 'public')
      event = FactoryBot.create(:event, event_type: event_type)
      expect(event.send(:calendar_id)).to eql(ENV['GOOGLE_CALENDAR_ID_TEST'])
    end

    context 'when in production' do
      it 'uses the education calendar for courses' do
        event_type = FactoryBot.create(:event_type, event_category: 'public')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.send(:calendar_id, prod: true)).to eql(ENV['GOOGLE_CALENDAR_ID_EDUC'])
      end

      it 'uses the education calendar for seminars' do
        event_type = FactoryBot.create(:event_type, event_category: 'seminar')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.send(:calendar_id, prod: true)).to eql(ENV['GOOGLE_CALENDAR_ID_EDUC'])
      end

      it 'uses the education calendar for meetings' do
        event_type = FactoryBot.create(:event_type, event_category: 'meeting')
        event = FactoryBot.create(:event, event_type: event_type)
        expect(event.send(:calendar_id, prod: true)).to eql(ENV['GOOGLE_CALENDAR_ID_GEN'])
      end
    end
  end

  describe 'all day' do
    it 'creates a valid event with the all_day flag set' do
      expect { FactoryBot.create(:event, all_day: true) }.not_to raise_error
    end
  end

  describe 'titles' do
    let(:event_type) { FactoryBot.create(:event_type) }

    it 'uses the event_type display_title without a summary' do
      event = FactoryBot.create(:event, event_type: event_type)
      expect(event.display_title).to eql(event_type.display_title)
    end

    it 'uses the summary when present' do
      event = FactoryBot.create(:event, event_type: event_type, summary: 'Name')
      expect(event.display_title).to eql('Name')
    end

    it 'generates the correct date_title' do
      event = FactoryBot.create(:event, event_type: event_type, start_at: '2018-04-07')
      expect(event.date_title).to eql("America's Boating Course – 4/7/2018")
    end
  end

  describe 'attach promo code' do
    let(:event_type) { FactoryBot.create(:event_type) }
    let(:event) { FactoryBot.create(:event, event_type: event_type) }

    it 'does not have a promo code attached on create' do
      expect(event.promo_codes).to be_blank
    end

    it 'correctlies attach a promo code when a match exists' do
      FactoryBot.create(:promo_code, code: 'prior_code')
      event.attach_promo_code('prior_code')
      expect(event.promo_codes.first.code).to eql('prior_code')
    end

    it 'correctlies attach a promo code when a match does not exist' do
      event.attach_promo_code('new_code')
      expect(event.promo_codes.first.code).to eql('new_code')
    end
  end

  describe 'repeat description' do
    let(:event_type) { FactoryBot.create(:event_type) }
    let(:event) { FactoryBot.create(:event, event_type: event_type, repeat_pattern: 'WEEKLY') }

    it 'returns the correct description for a daily event' do
      event.repeat_pattern = 'DAILY'
      expect(event.repeat_description).to eql('over consecutive days')
    end

    it 'returns the correct description for a weekly event' do
      expect(event.repeat_description).to eql('every week')
    end
  end

  describe 'public_link' do
    let(:event_type) { FactoryBot.create(:event_type) }
    let(:event) { FactoryBot.create(:event, event_type: event_type, repeat_pattern: 'WEEKLY') }

    it 'generates a normal link without a slug' do
      expect(event.public_link).to match(%r{courses/\d+\z})
    end

    it 'generates a slug link with a slug' do
      slug = SecureRandom.hex(16)
      event.update(slug: slug)
      expect(event.public_link).to match(%r{e/#{slug}\z})
    end

    it 'saves a downcased slug' do
      slug = SecureRandom.hex(16).upcase
      event.update(slug: slug)
      expect(event.public_link).to match(%r{e/#{slug.downcase}\z})
    end

    it 'generates the correct local path' do
      expect(event.path).to match(%r{courses/\d+\z})
    end
  end
end
