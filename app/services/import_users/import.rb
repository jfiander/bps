# frozen_string_literal: true

module ImportUsers
  # Main API for user importing
  class Import
    attr_reader :log_timestamp, :import_log_id

    def initialize(path, lock: false, jobcodes: [])
      @path = path
      @lock = lock
      @jobcodes = jobcodes
      @proto = BPS::Update::UserDataImport.new
      @certificates = []
      @completions = []
    end

    def call
      @parsed_csv = ImportUsers::ParseCSV.new(@path).call
      process_import
      process_jobcodes
      FileUtils.rm_f(@path)
      @import_log_id = ImportLog.create(proto: @proto.to_proto).id
      archive_proto
      @proto
    end

  private

    def process_import
      User.transaction do
        @parsed_csv.each { |row| process_row(row) }
        @families = ImportUsers::SetParents.new(@parsed_csv).call

        proto_completions
        proto_families

        lock_users = ImportUsers::LockUsers.new(@certificates)
        removed = @lock ? lock_users.call : lock_users.mark_not_imported

        removed.each do |user|
          u = BPS::Update::User.new(
            id: user.id, certificate: user.certificate, name: user.simple_name
          )
          @proto.not_in_import << u
        end
      end
    end

    def process_row(row)
      user, changes = ImportUsers::ParseRow.new(row).call
      record_results(user, changes)
      @completions << ImportUsers::CourseCompletions.new(user, row).call
    end

    def process_jobcodes
      jobcodes = ImportUsers::ImportJobcodes.new(@jobcodes)
      jobcodes.call

      @proto.jobcodes = BPS::Update::JobCodes.new(
        created: jobcodes.created.map(&:to_proto),
        expired: jobcodes.expired.map(&:to_proto)
      )
    end

    def record_results(user, changes)
      @certificates << user.certificate
      return if changes.blank?
      return proto_updated(user, changes) unless changes == :created

      @proto.created << BPS::Update::User.new(
        id: user.id, certificate: user.certificate, name: user.simple_name
      )
    end

    def proto_completions
      completions = @completions&.flatten&.group_by(&:user)
      completions_array = completions&.each_with_object([]) do |(user, comps), array|
        array << {
          user: { id: user.id, certificate: user.certificate, name: user.simple_name },
          completions: comps.map { |c| { key: c.course_key, date: c.date.to_time } }
        }
      end
      completions_array.each { |c| @proto.completions << BPS::Update::UserCompletion.new(c) }
    end

    def proto_families
      families_array = @families.each_with_object([]) do |(parent, family), array|
        array << {
          user: { id: parent.id },
          family: family.map { |user| { id: user.id } }
        }
      end
      families_array.each { |f| @proto.families << BPS::Update::UserFamily.new(f) }
    end

    def proto_updated(user, changes)
      @proto.updated << BPS::Update::UserUpdate.new(
        user: { id: user.id, certificate: user.certificate, name: user.simple_name },
        changes: changes.map do |field, (from, to)|
          { field: field, from: from.to_s, to: to.to_s }
        end
      )
    end

    def archive_proto
      archive = Rails.root.join('tmp/user_import.proto').open('wb')
      archive.write(@proto.to_proto)
      archive.rewind

      @log_timestamp = Time.now.to_i

      BPS::S3.new(:files).upload(file: archive, key: "user_imports/#{@log_timestamp}.proto")
    end
  end
end
