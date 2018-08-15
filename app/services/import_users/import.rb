# frozen_string_literal: true

module ImportUsers
  # Main API for user importing
  class Import
    def initialize(path, lock: false)
      @path = path
      @lock = lock
      @created = []
      @updated = []
      @certificates = []
    end

    def call
      @parsed_csv = ImportUsers::ParseCSV.new(@path).call
      process_import
      File.unlink(@path) if File.exist?(@path)
      results_hash
    end

    private

    def process_import
      User.transaction do
        @parsed_csv.each { |row| process_row(row) }
        @families = ImportUsers::SetParents.new(@parsed_csv).call
        @removed = @lock ? ImportUsers::LockUsers.new(@certificates).call : []
      end
    end

    def process_row(row)
      user, changes = ImportUsers::ParseRow.new(row).call
      record_results(user, changes)
      @completions = ImportUsers::CourseCompletions.new(user, row).call
    end

    def record_results(user, changes)
      @certificates << user.certificate
      return @created << user if changes == :created
      @updated << { user.id => changes } if changes.present?
    end

    def results_hash
      {
        created: @created&.map(&:id),
        updated: @updated&.reduce({}, :merge),
        completions: @completions&.map(&:id),
        families: @families,
        locked: @lock ? :skipped : @removed&.map(&:id)
      }
    end
  end
end
