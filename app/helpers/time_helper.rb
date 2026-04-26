# frozen_string_literal: true

module TimeHelper
  TIME = '%H%M'                                                   # 0000
  SHORT_DATE = '%-m/%-d'                                          # 1/1
  VERBOSE_DATE = '%a %d %b %Y'                                    # Tue 01 Jan 2019

  # rubocop:disable Layout/LineLength
  TIME_WITH_ZONE = "#{TIME} %Z".freeze                            # 0000 EST
  FULL_DATE = "#{SHORT_DATE}/%Y".freeze                           # 1/1/2019
  FULL_TIME_FORMAT = "%A %d %B %Y at #{TIME_WITH_ZONE}".freeze    # Tuesday 01 January 2019 at 0000 EST
  LONG_TIME_FORMAT = "#{VERBOSE_DATE} @ #{TIME_WITH_ZONE}".freeze # Tue 01 Jan 2019 @ 0000 EST
  MEDIUM_TIME_FORMAT = "#{FULL_DATE} @ #{TIME}".freeze            # 1/1/2019 @ 0000
  SHORT_TIME_FORMAT = "#{SHORT_DATE} @ #{TIME}".freeze            # 1/1 @ 0000
  PUBLIC_DATE_FORMAT = '%b %-d'                                   # Jan 1
  PUBLIC_TIME_FORMAT = '%l:%M %P %Z'                              # 12:00 am EST
  DURATION_FORMAT = '%-kh %Mm'                                    # 0h 00m
  ISO_TIME_FORMAT = '%Y-%m-%dT%H:%M'                              # 2019-01-01T00:00
  # rubocop:enable Layout/LineLength
end
