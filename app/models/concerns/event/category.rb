# frozen_string_literal: true

module Concerns
  module Event
    module Category
      extend ActiveSupport::Concern

      def category(event_types = nil)
        @course_ids = courses_from_cache(event_types).map(&:id)
        @seminar_ids = seminars_from_cache(event_types).map(&:id)
        @meeting_ids = meetings_from_cache(event_types).map(&:id)

        return 'course' if event_type_id.in? @course_ids
        return 'seminar' if event_type_id.in? @seminar_ids
        return 'meeting' if event_type_id.in? @meeting_ids

        event_type&.event_category
      end

      def category?(cat, event_types = nil)
        category(event_types) == cat.to_s
      end

      def course?(event_types = nil)
        category?('course', event_types)
      end

      def seminar?(event_types = nil)
        category?('seminar', event_types)
      end

      def meeting?(event_types = nil)
        category?('meeting', event_types)
      end

    private

      def courses_from_cache(event_types)
        return ::EventType.courses if event_types.nil?

        event_types.find_all do |e|
          e.event_category.to_s.in?(%w[public advanced_grade elective])
        end
      end

      def seminars_from_cache(event_types)
        return ::EventType.seminars if event_types.nil?

        event_types.find_all { |e| e.event_category.to_s.in?(['seminar']) }
      end

      def meetings_from_cache(event_types)
        return ::EventType.meetings if event_types.nil?

        event_types.find_all { |e| e.event_category.to_s.in?(['meeting']) }
      end
    end
  end
end
