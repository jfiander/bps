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

    def initialize
      @new_headers = []
      @file_headers = []
    end

    def update(download: true, import: true, lock: false)
      download_all if download
      combine_csv_data
      write_output_file
      return unless import

      result = ImportUsers::Import.new(OUTPUT_PATH, lock: lock).call
      cleanup_files
      result
    end

  private

    def download_all
      login

      REQUESTS.each do |name|
        puts "\nDownloading #{name}..."
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
        @new_headers += headers
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

    def write_output_file
      CSV.open(OUTPUT_PATH, 'w+') do |f|
        f << (main_csv.headers.to_a + @new_headers)
        main_csv.each { |row| f << normalize_row(row) unless skip(row) }
      end
    end

    def cleanup_files
      csv_paths.each do |path|
        File.unlink(path) if File.exist?(path)
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
  end
end
