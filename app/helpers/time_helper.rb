# frozen_string_literal: true

module TimeHelper
  FULL_TIME_FORMAT = '%A %d %B %Y at %H%M %Z' # Tuesday 01 January 2019 at 0000 EST
  LONG_TIME_FORMAT = '%a %d %b %Y @ %H%M %Z'  # Tue 01 Jan 2019 @ 0000 EST
  MEDIUM_TIME_FORMAT = '%-m/%-d/%Y @ %H%M'    # 1/1/2019 @ 0000
  SHORT_TIME_FORMAT = '%-m/%-d @ %H%M'        # 1/1 @ 0000
  EVENT_DATE_FORMAT = '%a %d %b %Y'           # Tue 01 Jan 2019
  SIMPLE_DATE_FORMAT = '%-m/%-d/%Y'           # 1/1/2019
  PUBLIC_DATE_FORMAT = '%b %-d'               # Jan 1
  PUBLIC_TIME_FORMAT = '%l:%M %P %Z'          # 12:00 am EST
  DURATION_FORMAT = '%-kh %Mm'                # 0h 00m
  ISO_TIME_FORMAT = '%Y-%m-%dT%H:%M'          # 2019-01-01T00:00
end
