# frozen_string_literal: true

require 'fileutils'

module AutomaticUpdate
  class Run
    OUTPUT_PATH = Rails.root.join('tmp/automatic_update/ReadyForImport.csv')

    attr_reader :log_timestamp, :import_log_id

    def initialize
      @file_headers = []
    end

    def update(_download: true, import: true, lock: false)
      combine_tsv_data_from_s3
      write_output_file
      automatic_updates_bucket.upload(file: OUTPUT_PATH, key: 'ReadyForImport.csv')
      return unless import

      importer = ImportUsers::Import.new(OUTPUT_PATH, lock: lock)
      proto = importer.call
      @log_timestamp = importer.log_timestamp
      @import_log_id = importer.import_log_id
      proto
    end

  private

    def automatic_updates_bucket
      BPS::S3.new(:automatic_updates)
    end

    def main_tsv
      @main_tsv ||= CSV.new(
        automatic_updates_bucket.download('member_info.tsv'), col_sep: "\t", headers: true
      ).map(&:to_h)
    end

    def combine_tsv_data_from_s3
      main_tsv.each do |row|
        row.merge!(*new_tsv_data.map do |tsv|
          tsv.find { |r| r['certno'] == row['certno'] }
        end.compact)
      end
    end

    def new_tsv_data
      @new_tsv_data ||= %i[courses seminars training boc].map do |key|
        CSV.new(
          automatic_updates_bucket.download("#{key}.tsv"), col_sep: "\t", headers: true
        ).map(&:to_h)
      end
    end

    def write_output_file
      FileUtils.mkdir_p(Rails.root.join('tmp/automatic_update'))
      headers = main_tsv.first.keys.to_a
      headers_count = headers.size
      CSV.open(OUTPUT_PATH, 'w+') do |f|
        f << headers
        main_tsv.each do |row|
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

    def normalize_row(row)
      row.map do |k, v|
        next nil if v.blank? || v.in?(['0', 0, '0000000000'])
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
