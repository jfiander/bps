# frozen_string_literal: true

module AutomaticUpdate
  class ClassDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/grades/doquery.cgi?%7C%7C%7Ctools'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_clmods.csv'
    REQUEST_DATA = {
      'mods' => 'clmods',
      'qtype' => 'spread',
      'cora' => 'C', 'grade' => 'X',
      'fld1' => 'N', 'fld2' => 'N', 'fld3' => 'N', 'fld4' => 'N', 'fld5' => 'N', 'fld6' => 'N',

      'fld7'  => 'Y', 'nam7'  => 'BC',
      'fld8'  => 'Y', 'nam8'  => 'S',
      'fld9'  => 'Y', 'nam9'  => 'BH',
      'fld10' => 'N', 'nam10' => 'S/BH', # Combined S-or-BH pass date
      'fld11' => 'Y', 'nam11' => 'P',
      'fld12' => 'Y', 'nam12' => 'AP',
      'fld13' => 'Y', 'nam13' => 'JN',
      'fld14' => 'Y', 'nam14' => 'N',
      'fld15' => 'Y', 'nam15' => 'CP',
      'fld16' => 'Y', 'nam16' => 'EM',
      'fld17' => 'Y', 'nam17' => 'ME',
      'fld18' => 'Y', 'nam18' => 'MES',
      'fld19' => 'Y', 'nam19' => 'MCS',
      'fld20' => 'Y', 'nam20' => 'MNS',
      'fld21' => 'Y', 'nam21' => 'RA',
      'fld22' => 'Y', 'nam22' => 'SA',
      'fld23' => 'Y', 'nam23' => 'WE',
      'fld24' => 'Y', 'nam24' => 'ID',
      'fld25' => 'Y', 'nam25' => 'IDEXPR',
      'fld26' => 'Y', 'nam26' => 'IQ'
    }.freeze
  end
end
