# frozen_string_literal: true

module ImportUsers
  # CSV parser for user importing
  class ParseCSV
    def initialize(path)
      @path = path
    end

    def call
      csv = CSV.parse(File.read(@path).force_encoding('UTF-8'), headers: true)
      raise 'Blank header(s) detected.' if csv.headers.any?(&:blank?)
      csv
    end
  end
end
