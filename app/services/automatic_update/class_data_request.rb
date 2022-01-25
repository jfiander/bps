# frozen_string_literal: true

module AutomaticUpdate
  class ClassDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/grades/docquery.cgi?%7C%7C'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_grades.csv'
    REQUEST_DATA = {
      'qtype' => 'spread',
      'cora' => 'C', 'grade' => 'X',
      'fld1' => 'N', 'fld2' => 'N', 'fld3' => 'N', 'fld4' => 'N', 'fld5' => 'N', 'fld6' => 'N',

      'fld7'  => 'Y', 'nam7'  => 'BC',
      'fld8'  => 'Y', 'nam8'  => 'S',
      'fld9'  => 'Y', 'nam9'  => 'BH',
      'fld10' => 'Y', 'nam10' => 'P',
      'fld11' => 'Y', 'nam11' => 'AP',
      'fld12' => 'Y', 'nam12' => 'JN',
      'fld13' => 'Y', 'nam13' => 'N',
      'fld14' => 'Y', 'nam14' => 'CP',
      'fld15' => 'Y', 'nam15' => 'EM',
      'fld16' => 'Y', 'nam16' => 'ME',
      'fld17' => 'Y', 'nam17' => 'MES',
      'fld18' => 'Y', 'nam18' => 'MCS',
      'fld19' => 'Y', 'nam19' => 'MNS',
      'fld20' => 'Y', 'nam20' => 'RA',
      'fld21' => 'Y', 'nam21' => 'SA',
      'fld22' => 'Y', 'nam22' => 'WE',
      'fld23' => 'Y', 'nam23' => 'ID',
      'fld24' => 'Y', 'nam24' => 'IDEXPR',
      'fld25' => 'Y', 'nam25' => 'IQ'
    }.freeze
  end
end
