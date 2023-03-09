# frozen_string_literal: true

module AutomaticUpdate
  # https://www.usps.org/cgi-bin-nat/grades/trmods.cgi
  class TrainingDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/grades/doquery.cgi?%7C%7C%7Ctools'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_trmods.csv'
    REQUEST_HEADER_DATA = {
      'mods' => 'trmods', 'qtype' => 'spread', 'cora' => 'C', 'grade' => 'X'
    }.freeze

    REQUEST_FIELD_NAMES = %w[
      LDP LDAO LDXO LDCDR VSC_01 OT OTUPD EMERW HURRW WEW CWFN LIVAWC OCCNAV OWAVNAV TSWFOR
    ].freeze
  end
end
