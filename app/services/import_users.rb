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
  FIELDS = YAML.safe_load(Rails.root.join('app/services/import_users/fields.yml').read)
  IMPORTED_FIELDS = ImportUsers::FIELDS['import'].freeze
  IGNORED_FIELDS = ImportUsers::FIELDS['ignore'].freeze
end
