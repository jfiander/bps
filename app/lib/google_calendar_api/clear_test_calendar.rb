# frozen_string_literal: true

module GoogleCalendarAPI::ClearTestCalendar
  def clear_test_calendar(page_token: nil, page_limit: 50)
    Google::Apis.logger.level = Logger::WARN
    set_page_token(page_token)
    loop_over_pages(ENV['GOOGLE_CALENDAR_ID_TEST'], page_limit: page_limit)
  rescue Google::Apis::RateLimitError
    puts "\n\n*** Google::Apis::RateLimitError (Rate Limit Exceeded)"
  ensure
    log_last_page_token
  end

  private

  def set_page_token(page_token)
    last_token = GoogleCalendarAPI::LAST_TOKEN_PATH
    @page_token ||= File.read(last_token) if File.exist?(last_token)
    @page_token = page_token if page_token.present?
  end

  def loop_over_pages(cal_id, page_limit: 50)
    puts "*** Starting with page token: #{@page_token}" if @page_token.present?

    while (@page_token = clear_page(cal_id)) && page_limit.positive?
      puts "*** Page token: #{@page_token}"
      page_limit -= 1
    end
  end

  def clear_page(cal_id)
    response = list(cal_id, page_token: @page_token)
    response.items&.each do |event|
      ExpRetry.new(exception: Google::Apis::RateLimitError).call do
        delete(cal_id, event.id)
        print '.'
      end
    end
    response.next_page_token
  end

  def log_last_page_token
    puts "\n\n*** Last page token cleared: #{@page_token}"
    File.open(GoogleCalendarAPI::LAST_TOKEN_PATH, 'w+') do |f|
      f.write(@page_token)
    end
    puts "\n*** Token stored in #{GoogleCalendarAPI::LAST_TOKEN_PATH}"
  end
end
