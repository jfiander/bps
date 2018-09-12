# frozen_string_literal: true

module ImportUsers
  # Course completion import for user importing
  class CourseCompletions
    def initialize(user, row)
      @user = user
      @row = row
      @completions = []
    end

    def call
      course_completions_data.each do |(key, date)|
        next unless (date = ImportUsers::CleanDate.new(date).call)

        @completions << create_completion(key, date) unless exists?(key, date)
      end

      @completions
    end

    private

    def create_completion(key, date)
      CourseCompletion.create!(
        user: @user, course_key: key, date: date
      )
    end

    def completion_ignored_columns
      ImportUsers::IMPORTED_FIELDS + ImportUsers::IGNORED_FIELDS
    end

    def course_completions_data
      @row.to_hash.except(*completion_ignored_columns)
    end

    def exists?(key, date)
      date.blank? ||
        CourseCompletion.find_by(user: @user, course_key: key).present?
    end
  end
end
