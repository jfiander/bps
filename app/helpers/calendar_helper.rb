module CalendarHelper
  def render_calendar(calendar_data = ENV['CALENDARS'])
    @calendar_data = calendar_data
    'https://calendar.google.com/calendar/b/2/embed?' +
      calendar_options +
      '&' +
      calendars
  end

  private

  def calendar_options
    {
      showTitle: 0,
      showPrint: 0,
      height: 600,
      wkst: 1,
      bgcolor: '%23FFFFFF',
      ctz: 'America%2FNew_York'
    }.map do |k, v|
      "#{k}=#{v}"
    end.join('&')
  end

  def calendars
    calendars_src.map do |src, color|
      "src=bpsd9.org_#{src}%40group.calendar.google.com&color=%23#{color}"
    end.join('&')
  end

  def calendars_src
    @calendar_data.split('/').map { |c| c.split(':') }
  end
end
