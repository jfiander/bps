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
        date = ImportUsers::CleanDate.new(date).call
        # raise [:cleaned_date, date].inspect if @user.certificate == 'E012345'
        next if course_completion_exists?(key, date)

        @completions << CourseCompletion.create!(
          user: @user, course_key: key, date: date
        )
      end

      @completions
    end

    private

    def course_completions_data
      @row.to_hash.except(
        'Certificate', 'HQ Rank', 'SQ Rank', 'Rank', 'First Name', 'Last Name',
        'Grade', 'Rank', 'E-Mail', 'MM', 'EdPro', 'EdAch', 'Senior', 'Life',
        'IDEXPR', 'City', 'State', 'Address 1', 'Address 2', 'Zip Code',
        'Home Phone', 'Cell Phone', 'Bus. Phone', 'Tot.Years', 'Prim.Cert'
      )
    end

    def course_completion_exists?(key, date)
      date.blank? ||
        CourseCompletion.find_by(user: @user, course_key: key).present?
    end
  end
end
