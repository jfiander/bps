# frozen_string_literal: true

module Roster
  class ArchiveFile < ::UploadedFile
    def self.table_name_prefix
      'roster_'
    end

    def self.archive!
      return :current if roster_generated_at == last&.generated_at

      download_current_roster
      create_new_archive(roster_generated_at)
    end

    def self.download_current_roster
      file = BPS::S3.new(:files).download("roster/#{roster_file_name}")
      Rails.root.join('tmp/run/roster.pdf').binwrite(file)
    end

    def self.create_new_archive(generated_at)
      file = Rails.root.join('tmp/run/roster.pdf').open
      Roster::ArchiveFile.create(file: file, generated_at: generated_at)
    end

    def self.roster_file_name
      year = Time.zone.today.strftime('%Y')
      "Birmingham_Power_Squadron_-_#{year}_Roster.pdf"
    end

    def self.roster_generated_at
      BPS::S3.new(:files).object("roster/#{roster_file_name}").last_modified
    end

    def link
      BPS::S3.new(:files).link(file.s3_object.key)
    end
  end
end
