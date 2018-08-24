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

  FIELDS ||= YAML.safe_load(
    File.read(
      File.join(Rails.root, 'app', 'services', 'import_users', 'fields.yml')
    )
  )

  IMPORTED_FIELDS ||= ImportUsers::FIELDS['import'].freeze
  IGNORED_FIELDS ||= ImportUsers::FIELDS['ignore'].freeze
end
