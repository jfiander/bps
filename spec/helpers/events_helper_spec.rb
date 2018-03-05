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
        @events = EventsHelper.get_events(:course)
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
        expect(EventsHelper.catalog).to eql(
          { 'public' => [@catalog_course] }
        )
      end
    end
  end
end
