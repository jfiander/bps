# frozen_string_literal: true

module ImportUsers
  # Date cleaner for user importing
  class CleanDate
    def initialize(string)
      @string = string
    end

    def call
      clean_date unless @string.blank?
    rescue StandardError
      puts "Invalid date: #{@string}" unless Rails.env.test?
    end

    private

    def clean_date
      datestring = @string.ljust(5, '0').ljust(6, '1')
      datestring[datestring.length - 1] = '1' if datestring.last(2) == '00'
      if datestring.length == 6
        Date.strptime(datestring, '%Y%m')
      elsif datestring.length == 8
        Date.strptime(datestring, '%Y%m%d')
      end
    end
  end
end
