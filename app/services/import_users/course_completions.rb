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
      completions_data.each { |(key, date)| process_completions(key, date) }

      @completions
    end

  private

    def process_completions(key, date)
      return unless (date = ImportUsers::CleanDate.new(date, key: key).call)
      return if exists?(key, date)

      @completions << create_completion(key, date)
    end

    def create_completion(key, date)
      CourseCompletion.create!(
        user: @user, course_key: key, date: date
      )
    end

    def ignored_columns
      ImportUsers::IMPORTED_FIELDS + ImportUsers::IGNORED_FIELDS
    end

    def completions_data
      @row.to_hash.except(*ignored_columns)
    end

    def exists?(key, date)
      date.blank? ||
        CourseCompletion.find_by(user: @user, course_key: key).present?
    end
  end
end
