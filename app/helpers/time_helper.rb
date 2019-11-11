# frozen_string_literal: true

module TimeHelper
  FULL_TIME_FORMAT = '%A %d %B %Y at %H%M %Z'
  LONG_TIME_FORMAT = '%a %d %b %Y @ %H%M %Z'
  MEDIUM_TIME_FORMAT = '%-m/%-d/%Y @ %H%M'
  SHORT_TIME_FORMAT = '%-m/%-d @ %H%M'
  EVENT_DATE_FORMAT = '%a %d %b %Y'
  SIMPLE_DATE_FORMAT = '%-m/%-d/%Y'
  PUBLIC_DATE_FORMAT = '%b %-d'
  PUBLIC_TIME_FORMAT = '%l:%M %P %Z'
  DURATION_FORMAT = '%-kh %Mm'
  ISO_TIME_FORMAT = '%Y-%m-%dT%H:%M'
end
