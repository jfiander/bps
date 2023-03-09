# frozen_string_literal: true

module AutomaticUpdate
  # https://www.usps.org/cgi-bin-nat/grades/clmods.cgi
  class ClassDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/grades/doquery.cgi?%7C%7C%7Ctools'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_clmods.csv'
    REQUEST_HEADER_DATA = {
      'mods' => 'clmods', 'qtype' => 'spread', 'cora' => 'C', 'grade' => 'X'
    }.freeze

    # S/BH:  Combined S-or-BH pass date
    # PI/N1: Combined P-or-MN pass date
    REQUEST_FIELD_NAMES = %w[
      BC S BH S/BH P N1 PI/N1 AP JN N CP EM ME MES MCS MNS RA SA WE ID IDEXPR IQ
    ].freeze
  end
end
