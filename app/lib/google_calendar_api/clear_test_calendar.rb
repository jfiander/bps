# frozen_string_literal: true

module GoogleCalendarAPI::ClearTestCalendar
  RETRIABLE_EXCEPTIONS = [
    Google::Apis::RateLimitError,
    Google::Apis::TransmissionError
  ].freeze

  def clear_test_calendar(page_token: nil, page_limit: 50)
    Google::Apis.logger.level = Logger::WARN
    set_page_token(page_token)
    loop_over_pages(ENV['GOOGLE_CALENDAR_ID_TEST'], page_limit: page_limit)
    puts '*** Cleared all events!'
  rescue Google::Apis::RateLimitError
    puts "\n\n*** Google::Apis::RateLimitError (Rate Limit Exceeded)"
  ensure
    log_last_page_token unless @page_token.blank?
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
      page_limit -= 1
    end
  end

  def clear_page(cal_id)
    response = list(cal_id, page_token: @page_token)
    clear_events_from_page(cal_id, response.items) unless response.items.blank?
    response.next_page_token
  end

  def clear_events_from_page(cal_id, items)
    puts "*** Page token: #{@page_token}"
    pb = progress_bar(items.count)
    items&.each_with_index do |event, index|
      ExpRetry.for(exception: RETRIABLE_EXCEPTIONS) do
        delete(cal_id, event.id)
        pb.increment
      end
    end
  end

  def log_last_page_token
    puts "\n\n*** Last page token cleared: #{@page_token}"
    File.open(GoogleCalendarAPI::LAST_TOKEN_PATH, 'w+') do |f|
      f.write(@page_token)
    end
    puts "\n*** Token stored in #{GoogleCalendarAPI::LAST_TOKEN_PATH}"
  end

  def progress_bar(total)
    ProgressBar.create(title: 'Page cleared', starting_at: 0, total: total, format: "%a [%R/sec] %E | %b\u{15E7}%i %c/%C (%P%%) %t", progress_mark: ' ', remainder_mark: "\u{FF65}")
  end
end
