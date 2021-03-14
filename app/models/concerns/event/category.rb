# frozen_string_literal: true

module Concerns
  module Event
    module Category
      COURSE_CATEGORIES = %w[public advanced_grade elective].freeze

      extend ActiveSupport::Concern

      def category
        cat = event_type&.event_category
        cat.in?(COURSE_CATEGORIES) ? 'course' : cat
      end

      def category?(cat)
        category == cat.to_s
      end

      def course?
        category?('course')
      end

      def seminar?
        category?('seminar')
      end

      def meeting?
        category?('meeting')
      end
    end
  end
end
