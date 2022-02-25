# frozen_string_literal: true

module AutomaticUpdate
  class BOCDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/grades/doquery.cgi?%7C%7C%7Ctools'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_bocmods.csv'
    REQUEST_DATA = {
      'mods' => 'bocmods',
      'qtype' => 'spread', 'cora' => 'C', 'grade' => 'X',
      'fld1' => 'N', 'fld2' => 'N', 'fld3' => 'N', 'fld4' => 'N', 'fld5' => 'N', 'fld6' => 'N',

      'fld7'  => 'Y', 'nam7'  => 'BOC_IN',
      'fld8'  => 'Y', 'nam8'  => 'BOC_CN',
      'fld9'  => 'Y', 'nam9'  => 'BOC_ACN',
      'fld10' => 'Y', 'nam10' => 'BOC_ON',
      'fld11' => 'Y', 'nam11' => 'BOC_CAN',
      'fld12' => 'Y', 'nam12' => 'CE',
      'fld13' => 'Y', 'nam13' => 'EUR',
      'fld14' => 'Y', 'nam14' => 'BOC_IW',
      'fld15' => 'Y', 'nam15' => 'BOC_MEX',
      'fld16' => 'Y', 'nam16' => 'BOC_PAD',
      'fld17' => 'Y', 'nam17' => 'BOC_SA',
      'fld18' => 'Y', 'nam18' => 'BOC_SAX',
      'fld19' => 'Y', 'nam19' => 'BOCTRN',
      'fld20' => 'Y', 'nam20' => 'CPR',
      'fld21' => 'Y', 'nam21' => 'FAID',
      'fld22' => 'Y', 'nam22' => 'FIRE',
      'fld23' => 'Y', 'nam23' => 'PYROD',
      'fld24' => 'Y', 'nam24' => 'OTWBPH',
      'fld25' => 'Y', 'nam25' => 'OTWNAV',
      'fld26' => 'Y', 'nam26' => 'OTWADN',
      'fld27' => 'Y', 'nam27' => 'OTWONC'
    }.freeze
  end
end
