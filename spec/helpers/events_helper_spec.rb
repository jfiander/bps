# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsHelper, type: :helper do
  describe 'cache loaders' do
    before(:each) do
      @public = FactoryBot.create(:event_type, event_category: 'public')
      @ag = FactoryBot.create(:event_type, event_category: 'advanced_grade')
      @public = FactoryBot.create(:event_type, event_category: 'elective')
      @seminar = FactoryBot.create(:event_type, event_category: 'seminar')
      @meeting = FactoryBot.create(:event_type, event_category: 'meeting')
      @catalog_course = FactoryBot.create(:event, show_in_catalog: true)
      EventsHelper.preload_events
    end

    describe 'courses' do
      before(:each) do
        @events = EventsHelper.get_events('course')
        @course = FactoryBot.create(:event)
      end

      it 'should return the event_type' do
        @course = FactoryBot.create(:event, event_type: @ag)
        expect(EventsHelper.event_type(@course)).to eql(@ag)
      end

      it 'should return the prereq' do
        @course = FactoryBot.create(:event, prereq: @elective)
        expect(EventsHelper.event_prereq(@course)).to eql(@elective)
      end

      it 'should return the instructors' do
        @course = FactoryBot.create(:event, :with_instructor)
        expect(EventsHelper.event_instructors(@course)).to eql(
          @course.instructors.to_a
        )
      end

      it 'should return the topics' do
        @course = FactoryBot.create(:event, :with_topics)
        expect(EventsHelper.course_topics(@course)).to eql(
          @course.course_topics.to_a
        )
      end

      it 'should return the includes' do
        @course = FactoryBot.create(:event, :with_includes)
        expect(EventsHelper.course_includes(@course)).to eql(
          @course.course_includes.to_a
        )
      end
    end

    describe 'seminars' do
      before(:each) do
        EventsHelper.get_events(:seminar)
      end

      it 'should return the event_type' do
        @sem = FactoryBot.create(:event, event_type: @seminar)
        expect(EventsHelper.event_type(@sem)).to eql(@seminar)
      end
    end

    describe 'events' do
      before(:each) do
        EventsHelper.get_events(:event)
      end

      it 'should return the event_type' do
        @meet = FactoryBot.create(:event, event_type: @meeting)
        expect(EventsHelper.event_type(@meet)).to eql(@meeting)
      end
    end

    describe 'catalog' do
      it 'should return only the catalog events' do
        expect(EventsHelper.catalog_list).to eql(
          'public' => [@catalog_course]
        )
      end
    end

    describe 'action link' do
      it 'should generate a correct action link' do
        @course = FactoryBot.create(:event, event_type: @ag)

        link = event_action_link(
          @course, 'book_course_path',
          icon: 'calendar-check', text: 'Post to Calendar',
          css: 'birmingham-blue', method: :put
        )

        expect(link).to eql(
          '<a icon="calendar-check" text="Post to Calendar" ' \
          'class="control birmingham-blue" css="birmingham-blue" ' \
          'rel="nofollow" data-method="put" href="/courses/2/book">' \
          '<i class=\'far fa-fw fa-calendar-check fa-1x\' ' \
          'data-fa-transform=\'\' title=\'\'></i>Post To Calendar</a>'
        )
      end

      it 'should generate a correct action link with a non-method path' do
        @course = FactoryBot.create(:event, event_type: @ag)

        link = event_action_link(
          @course, 'http://example.com',
          icon: 'calendar-check', text: 'Post to Calendar',
          css: 'birmingham-blue', method: :put
        )

        expect(link).to eql(
          '<a icon="calendar-check" text="Post to Calendar" ' \
          'class="control birmingham-blue" css="birmingham-blue" ' \
          'rel="nofollow" data-method="put" href="http://example.com">' \
          '<i class=\'far fa-fw fa-calendar-check fa-1x\' ' \
          'data-fa-transform=\'\' title=\'\'></i>Post To Calendar</a>'
        )
      end

      it 'should generate just an icon with a nil path' do
        @course = FactoryBot.create(:event, event_type: @ag)

        link = event_action_link(
          @course, nil,
          icon: 'calendar-check', text: 'Post to Calendar',
          css: 'birmingham-blue', method: :put
        )

        expect(link).to eql(
          '<i class=\'far fa-fw fa-calendar-check fa-1x\' ' \
          'data-fa-transform=\'\' title=\'\'></i>Post To Calendar'
        )
      end
    end
  end
end
