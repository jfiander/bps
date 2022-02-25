# frozen_string_literal: true

module AutomaticUpdate
  class SeminarDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/grades/doquery.cgi?%7C%7C%7Ctools'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_smmods.csv'
    REQUEST_DATA = {
      'mods' => 'smmods',
      'qtype' => 'spread', 'cora' => 'C', 'grade' => 'X',
      'fld1' => 'N', 'fld2' => 'N', 'fld3' => 'N', 'fld4' => 'N', 'fld5' => 'N', 'fld6' => 'N',

      'fld7'  => 'Y', 'nam7'  => 'ADVPBH',
      'fld8'  => 'Y', 'nam8'  => 'AIS',
      'fld9'  => 'Y', 'nam9'  => 'ANCHOR',
      'fld10' => 'Y', 'nam10' => 'BCNAV',
      'fld11' => 'Y', 'nam11' => 'BHANCH',
      'fld12' => 'Y', 'nam12' => 'BHBOAT',
      'fld13' => 'Y', 'nam13' => 'BHDOCK',
      'fld14' => 'Y', 'nam14' => 'BHEMER',
      'fld15' => 'Y', 'nam15' => 'BHKNOTS',
      'fld16' => 'Y', 'nam16' => 'BHPWR',
      'fld17' => 'Y', 'nam17' => 'BHRULES',
      'fld18' => 'Y', 'nam18' => 'BRLL',
      'fld19' => 'Y', 'nam19' => 'BWF',
      'fld20' => 'Y', 'nam20' => 'CBS',
      'fld21' => 'Y', 'nam21' => 'CHART1',
      'fld22' => 'Y', 'nam22' => 'CROSSB',
      'fld23' => 'Y', 'nam23' => 'EMEROB',
      'fld24' => 'Y', 'nam24' => 'EPIRB',
      'fld25' => 'Y', 'nam25' => 'FUEL',
      'fld26' => 'Y', 'nam26' => 'GPS1',
      'fld27' => 'Y', 'nam27' => 'HURRICN',
      'fld28' => 'Y', 'nam28' => 'INTNAV',
      'fld29' => 'Y', 'nam29' => 'KNOTS',
      'fld30' => 'Y', 'nam30' => 'MOB',
      'fld31' => 'Y', 'nam31' => 'MRNCOMP',
      'fld32' => 'Y', 'nam32' => 'MWF',
      'fld33' => 'Y', 'nam33' => 'OBWF',
      'fld34' => 'Y', 'nam34' => 'PADSM',
      'fld35' => 'Y', 'nam35' => 'PIC',
      'fld36' => 'Y', 'nam36' => 'POWTR',
      'fld37' => 'Y', 'nam37' => 'PROPAN',
      'fld38' => 'Y', 'nam38' => 'PWC_O',
      'fld39' => 'Y', 'nam39' => 'PYCRUS',
      'fld40' => 'Y', 'nam40' => 'RADAR',
      'fld41' => 'Y', 'nam41' => 'RULES',
      'fld42' => 'Y', 'nam42' => 'SAILTR',
      'fld43' => 'Y', 'nam43' => 'TIDCUR',
      'fld44' => 'Y', 'nam44' => 'TRLRN',
      'fld45' => 'Y', 'nam45' => 'VHFDSC'
    }.freeze
  end
end
