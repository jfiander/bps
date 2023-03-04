# frozen_string_literal: true

module AutomaticUpdate
  require 'automatic_update/login_request'
  require 'automatic_update/member_data_request'
  require 'automatic_update/class_data_request'
  require 'automatic_update/seminar_data_request'
  require 'automatic_update/training_data_request'
  require 'automatic_update/boc_data_request'

  REQUESTS = %i[
    MemberDataRequest ClassDataRequest SeminarDataRequest
    TrainingDataRequest BOCDataRequest
  ].freeze

  class Run
    OUTPUT_PATH = Rails.root.join('tmp/automatic_update/ReadyForImport.csv')
    CACHE_DOWNLOADS_PATH = Rails.root.join('tmp/automatic_update/cache_downloads')

    attr_reader :log_timestamp, :import_log_id

    def initialize
      @file_headers = []
    end

    def update(download: true, import: true, lock: false)
      download_all if download && !File.exist?(OUTPUT_PATH)
      combine_csv_data
      validate_combined_csv
      write_output_file
      return unless import

      importer = ImportUsers::Import.new(OUTPUT_PATH, lock: lock)
      proto = importer.call
      @log_timestamp = importer.log_timestamp
      @import_log_id = importer.import_log_id
      cleanup_files unless File.exist?(CACHE_DOWNLOADS_PATH)
      proto
    end

  private

    def download_all
      login

      REQUESTS.each do |name|
        req = AutomaticUpdate.const_get(name).new(@cookie_key, verbose: true)
        req.call
        req.download
      end
    end

    def login
      result = AutomaticUpdate::LoginRequest.new.call

      cookies = result.response['set-cookie']
                      .split(/; ?/).map { |s| s.split('=') }.to_h

      @cookie_key = cookies['uspskey']
    end

    def csv_paths
      @csv_paths ||= REQUESTS.map do |name|
        Rails.root.join("tmp/automatic_update/#{name}.csv")
      end
    end

    def main_csv
      @main_csv ||= CSV.read(csv_paths.shift, headers: true)
    end

    def new_data
      @new_data ||= csv_paths.map do |path|
        csv = CSV.read(path, headers: true)
        headers = csv.headers
        headers.shift # Ignore cert# header
        @file_headers.push(headers) # Track the groups of headers to ensure consistency

        csv.each_with_object({}) do |row, hash|
          certificate = row.delete('cert#').last
          hash[certificate] = row
        end
      end
    end

    def combine_csv_data
      main_csv.each do |row|
        new_data.each_with_index do |file, index|
          unless file.key?(row['Certificate'])
            @file_headers[index].each { |k| row[k] = nil }
            next
          end

          file[row['Certificate']].each { |k, v| row[k] = v }
        end
      end
    end

    def validate_combined_csv
      return if main_csv.headers.uniq == main_csv.headers

      raise ErrorWithDetails.call(
        InvalidCSVHeadersError,
        'Invalid CSV headers',
        actual: main_csv.headers
      )
    end

    def write_output_file
      headers = main_csv.headers.to_a
      headers_count = headers.size
      CSV.open(OUTPUT_PATH, 'w+') do |f|
        f << headers
        main_csv.each do |row|
          next if skip(row)

          new_row = normalize_row(row)

          raise error_with_details(row, headers_count, headers) unless row.length == headers_count

          f << new_row
        end
      end
    end

    def error_with_details(row, headers_count, headers)
      ErrorWithDetails.call(
        InvalidCSVHeadersError,
        'Unexpected column count',
        certificate: row['Certificate'],
        expected_count: headers_count,
        actual_count: row.length,
        expected: headers,
        actual: row.headers,
        row: row
      )
    end

    def cleanup_files
      csv_paths.each do |path|
        FileUtils.rm_f(path)
      end
    end

    def normalize_row(row)
      row.to_h.map do |k, v|
        next nil if v.blank?
        next nil if v.in?(['0', 0])
        next v.split('-').first if k == 'Grade'
        next v.gsub(/1st/, '1') if k == 'HQ Rank'
        next v.gsub(/(.{3})(.{3})(.{4})/, '\1 \2-\3') if k =~ / Phone$/

        v
      end
    end

    def skip(row)
      row['Member Type'] == 'HR' # Honorary Member
    end

    class InvalidCSVHeadersError < BPS::ErrorWithMetadata
      def bugsnag_meta_data
        {
          summary: {
            certificate: metadata[:certificate],
            expected_count: metadata[:expected_count],
            actual_count: metadata[:actual_count]
          },
          headers: {
            expected: metadata[:expected],
            actual: metadata[:actual]
          },
          row: metadata[:row]&.to_h
        }
      end
    end
  end
end
