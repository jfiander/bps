# frozen_string_literal: true

# Export all columns in the following list:
#
# 'Certificate', 'HQ Rank', 'SQ Rank', 'First Name', 'Last Name',
# 'Grade', 'Rank', 'E-Mail', 'MM', 'EdPro', 'EdAch', 'Senior', 'Life',
# 'IDEXPR', 'Address 1', 'Address 2', 'City', 'State', 'Zip Code',
# 'Home Phone', 'Cell Phone', 'Bus. Phone', 'Tot.Years', 'Prim.Cert'
#
# As well as all educational columns. You can also add a manual 'Rank' column.
#
module ImportUsers
  require 'import_users/import'
  require 'import_users/parse_csv'
  require 'import_users/parse_row'
  require 'import_users/clean_date'
  require 'import_users/course_completions'
  require 'import_users/set_parents'
  require 'import_users/lock_users'
  require 'import_users/hash'

  IMPORTED_FIELDS ||= [
    'Certificate', 'HQ Rank', 'SQ Rank', 'Rank', 'First Name', 'Last Name',
    'Grade', 'Rank', 'E-Mail', 'MM', 'EdPro', 'EdAch', 'Senior', 'Life',
    'IDEXPR', 'City', 'State', 'Address 1', 'Address 2', 'Zip Code',
    'Home Phone', 'Cell Phone', 'Bus. Phone', 'Tot.Years', 'Prim.Cert',
    'Cert. Date'
  ].freeze

  IGNORED_FIELDS ||= [
    'DA', 'H/A', 'Birthday', 'Sex', 'Spouse', 'Spo Cert.', 'Spo Sex', 'Wedding',
    'Nickname', 'NN Prf', 'Seascout', 'Affiliation', 'Org.Sqd', 'Org.Dst',
    'Pre.Sqd', 'Pre.Dst', 'Last BDU', 'Last HQ', 'Type / Status Desc.',
    'Type / Status Code', 'Transfer', 'Telephone', 'Fax Phone', '< Test', 'Ext',
    'OK', 'MMSI', 'Call Sign', 'Boat Name', 'Boat Type', 'Home Port', 'OAL',
    'Beam', 'Draft', 'Power', 'Fuel Capacity', 'Speed', 'Range', 'Clearance',
    'Berths', 'Squadron 1', 'Squadron 2', 'Dist No', 'Squad No.', 'Squad. Code',
    'Squad. Name'
  ].freeze
end
