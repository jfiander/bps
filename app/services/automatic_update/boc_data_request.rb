# frozen_string_literal: true

module AutomaticUpdate
  # https://www.usps.org/cgi-bin-nat/grades/bocmods.cgi
  class BOCDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/grades/doquery.cgi?%7C%7C%7Ctools'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_bocmods.csv'
    REQUEST_HEADER_DATA = {
      'mods' => 'bocmods', 'qtype' => 'spread', 'cora' => 'C', 'grade' => 'X'
    }.freeze

    REQUEST_FIELD_NAMES = %w[
      BOC_IN BOC_CN BOC_ACN BOC_ON
      BOC_CAN CE EUR BOC_IW BOC_MEX BOC_PAD BOC_SA BOC_SAX
      BOCTRN CPR FAID FIRE PYROD
      OTWBPH OTWNAV OTWADN OTWONC
    ].freeze
  end
end
