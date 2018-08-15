# frozen_string_literal: true

module ImportUsers
  # Date cleaner for user importing
  class CleanDate
    def initialize(string)
      @string = string
    end

    def call
      clean_date
    rescue ArgumentError => e
      handle_invalid_date(e)
    end

    private

    def clean_date
      return if @string.blank?
      datestring = @string.ljust(5, '0').ljust(6, '1')
      datestring[datestring.length - 1] = '1' if datestring.last(2) == '00'
      parse_date(datestring)
    end

    def parse_date(datestring)
      if datestring.length == 6
        Date.strptime(datestring, '%Y%m')
      elsif datestring.length == 8
        Date.strptime(datestring, '%Y%m%d')
      end
    end

    def handle_invalid_date(error)
      raise error unless error.message == 'invalid date'
      puts 'Invalid date' unless Rails.env.test?
    end
  end
end
