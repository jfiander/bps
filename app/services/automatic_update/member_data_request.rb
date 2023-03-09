# frozen_string_literal: true

module AutomaticUpdate
  # https://www.usps.org/cgi-bin-nat/org/makecsv.cgi?|S|`
  class MemberDataRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/cgi-bin-nat/org/docsv.cgi?%7CS%7C'
    DOWNLOAD_URL = 'https://www.usps.org/info/temp/0525_9_Birmingham_member.csv'
    REQUEST_DATA = {
      'members' => 'Y', 'honorary' => 'Y',

      'dformat' => '1', 'pformat' => '1', 'zformat' => '1',

      'certno'    => 'Y', 'certnonm'    => 'Certificate',      'certnonbr'     => '1',
      'first'     => 'Y', 'firstnm'     => 'First Name',       'firstnbr'      => '2',
      'last'      => 'Y', 'lastnm'      => 'Last Name',        'lastnbr'       => '3',
      'rank'      => 'Y', 'ranknm'      => 'HQ Rank',          'ranknbr'       => '4',
      'pastrank'  => 'Y', 'pastranknm'  => 'Past Rank',        'pastranknbr'   => '5',
      'grade'     => 'Y', 'gradenm'     => 'Grade',            'gradenbr'      => '6',
      'nick'      => 'Y', 'nicknm'      => 'Nickname',         'nicknbr'       => '7',
      'nickpref'  => 'Y', 'nickprefnm'  => 'NN Prf',           'nickprefnbr'   => '8',
      'sex'       => 'Y', 'sexnm'       => 'Sex',              'sexnbr'        => '9',
      'mbrtype'   => 'Y', 'mbrtypenm'   => 'Member Type',      'mbrtypenbr'    => '10',
      'birth'     => 'Y', 'birthnm'     => 'Birthday',         'birthnbr'      => '11',
      'bdisp'     => 'Y', 'bdispnm'     => 'Birthday Display', 'bdispnbr'      => '12',
      'spcertno'  => 'Y', 'spcertnonm'  => 'Spo Cert.',        'spcertnonbr'   => '13',
      'spouse'    => 'Y', 'spousenm'    => 'Spouse',           'spousenbr'     => '14',
      'ssex'      => 'Y', 'ssexnm'      => 'Spo Sex',          'ssexnbr'       => '15',
      'address1'  => 'Y', 'address1nm'  => 'Address 1',        'address1nbr'   => '16',
      'address2'  => 'Y', 'address2nm'  => 'Address 2',        'address2nbr'   => '17',
      'city'      => 'Y', 'citynm'      => 'City',             'citynbr'       => '18',
      'state'     => 'Y', 'statenm'     => 'State',            'statenbr'      => '19',
      'zip5'      => 'Y', 'zip5nm'      => 'Zip Code',         'zip5nbr'       => '20',
      'zip4'      => 'Y', 'zip4nm'      => 'Zip+4',            'zip4nbr'       => '21',
      'account'   => 'Y', 'accountnm'   => 'Squad No.',        'accountnbr'    => '22',
      'sqname'    => 'Y', 'sqnamenm'    => 'Squad. Name',      'sqnamenbr'     => '23',
      'distno'    => 'Y', 'distnonm'    => 'Dist No',          'distnonbr'     => '24',
      'years'     => 'Y', 'yearsnm'     => 'Tot.Years',        'yearsnbr'      => '25',
      'mm'        => 'Y', 'mmnm'        => 'MM',               'mmnbr'         => '26',
      'lastmm'    => 'Y', 'lastmmnm'    => 'Last MM',          'lastmmnbr'     => '27',
      'senior'    => 'Y', 'seniornm'    => 'Senior',           'seniornbr'     => '28',
      'life'      => 'Y', 'lifenm'      => 'Life',             'lifenbr'       => '29',
      'mbrdate'   => 'Y', 'mbrdatenm'   => 'Cert. Date',       'mbrdatenbr'    => '30',
      'edpro'     => 'Y', 'edpronm'     => 'EdPro',            'edpronbr'      => '31',
      'edach'     => 'Y', 'edachnm'     => 'EdAch',            'edachnbr'      => '32',
      'phone'     => 'Y', 'phonenm'     => 'Home Phone',       'phonenbr'      => '33',
      'text'      => 'Y', 'textnm'      => 'Home Text',        'textnbr'       => '34',
      'phone2'    => 'Y', 'phone2nm'    => 'Bus. Phone',       'phone2nbr'     => '35',
      'text2'     => 'Y', 'text2nm'     => 'Bus. Text',        'text2nbr'      => '36',
      'ext'       => 'Y', 'extnm'       => 'Ext',              'extnbr'        => '37',
      'ok'        => 'Y', 'oknm'        => 'OK',               'oknbr'         => '38',
      'phonec'    => 'Y', 'phonecnm'    => 'Cell Phone',       'phonecnbr'     => '39',
      'textc'     => 'Y', 'textcnm'     => 'Cell Text',        'textcnbr'      => '40',
      'fax'       => 'Y', 'faxnm'       => 'Fax',              'faxnbr'        => '41',
      'email'     => 'Y', 'emailnm'     => 'E-Mail',           'emailnbr'      => '42',
      'estatus'   => 'Y', 'estatusnm'   => '< Test',           'estatusnbr'    => '43',
      'callsign'  => 'Y', 'callsignnm'  => 'Callsign',         'callsignnbr'   => '44',
      'btype'     => 'Y', 'btypenm'     => 'Boat Type',        'btypenbr'      => '45',
      'bname'     => 'Y', 'bnamenm'     => 'Boat Name',        'bnamenbr'      => '46',
      'actcertno' => 'Y', 'actcertnonm' => 'Prim.Cert',        'actcertnonbr'  => '47',
      'job'       => 'Y', 'jobnm'       => 'Squad. Job',       'jobnbr'        => '48',
      'vsc'       => 'Y', 'vscnm'       => 'VSC_01',           'vscnbr'        => '49'
      # Former fields that have been removed: port, mmsi
    }.freeze

  private

    def request_data
      REQUEST_DATA
    end
  end
end
