# frozen_string_literal: true

module AutomaticUpdate
  # https://www.usps.org/cgi-bin-nat/grades/smmods.cgi
  class SeminarDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/grades/doquery.cgi?%7C%7C%7Ctools'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_smmods.csv'
    REQUEST_HEADER_DATA = {
      'mods' => 'smmods', 'qtype' => 'spread', 'cora' => 'C', 'grade' => 'X'
    }.freeze

    REQUEST_FIELD_NAMES = %w[
      ADVPBH AIS ANCHOR BCNAV BHANCH BHBOAT BHDOCK BHEMER BHKNOTS BHPWR BHRULES BRLL BWF CBS CHART1
      CROSSB EMEROB EPIRB FUEL GPS1 HURRICN INTNAV KNOTS MOB MRNCOMP MWF OBWF PADSM PIC POWTR PROPAN
      PWC_O PYCRUS RADAR RULES SAILTR TIDCUR TRLRN VHFDSC
    ].freeze
  end
end
