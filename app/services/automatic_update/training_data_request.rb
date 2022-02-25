# frozen_string_literal: true

module AutomaticUpdate
  class TrainingDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/grades/doquery.cgi?%7C%7C%7Ctools'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_trmods.csv'
    REQUEST_DATA = {
      'mods' => 'trmods',
      'qtype' => 'spread', 'cora' => 'C', 'grade' => 'X',
      'fld1' => 'N', 'fld2' => 'N', 'fld3' => 'N', 'fld4' => 'N', 'fld5' => 'N', 'fld6' => 'N',

      'fld7'  => 'Y', 'nam7'  => 'LDP',
      'fld8'  => 'Y', 'nam8'  => 'LDAO',
      'fld9'  => 'Y', 'nam9'  => 'LDXO',
      'fld10' => 'Y', 'nam10' => 'LDCDR',
      'fld11' => 'Y', 'nam11' => 'VSC_01',
      'fld12' => 'Y', 'nam12' => 'OT',
      'fld13' => 'Y', 'nam13' => 'OTUPD',
      'fld14' => 'Y', 'nam14' => 'EMERW',
      'fld15' => 'Y', 'nam15' => 'HURRW',
      'fld16' => 'Y', 'nam16' => 'WEW',
      'fld17' => 'Y', 'nam17' => 'CWFN',
      'fld18' => 'Y', 'nam18' => 'LIVAWC',
      'fld19' => 'Y', 'nam19' => 'OCCNAV',
      'fld20' => 'Y', 'nam20' => 'OWAVNAV',
      'fld21' => 'Y', 'nam21' => 'TSWFOR'
    }.freeze
  end
end
