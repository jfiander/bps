# frozen_string_literal: true

module ImportUsers
  # Main API for user importing
  class Import
    def initialize(path, lock: false)
      @path = path
      @lock = lock
      @proto = BPS::Update::UserDataImport.new
      @created = []
      @updated = {}
      @certificates = []
      @completions = []
    end

    def call
      @parsed_csv = ImportUsers::ParseCSV.new(@path).call
      process_import
      File.unlink(@path) if File.exist?(@path)
      results = results_hash
      ImportLog.create(json: results.to_json, proto: @proto.to_proto)
      results
    end

  private

    def process_import
      User.transaction do
        @parsed_csv.each { |row| process_row(row) }
        @families = ImportUsers::SetParents.new(@parsed_csv).call

        proto_completions
        proto_families

        lock_users = ImportUsers::LockUsers.new(@certificates)
        @removed = @lock ? lock_users.call : lock_users.mark_not_imported

        @removed.each do |user|
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

    def record_results(user, changes)
      @certificates << user.certificate
      if changes == :created
        @proto.created << BPS::Update::User.new(
          id: user.id, certificate: user.certificate, name: user.simple_name
        )
        return @created << user
      end

      proto_updated(user, changes) if changes.present?
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
      @updated[user] = changes
    end

    def results_hash
      {
        created: @created,
        updated: @updated,
        completions: @completions&.flatten&.group_by(&:user),
        completion_ids: @completions&.flatten&.map(&:id),
        families: @families,
        locked: @lock ? @removed : :skipped,
        proto: @proto
      }
    end
  end
end
