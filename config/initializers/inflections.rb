# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'AED'
  inflect.acronym 'CPR'
  inflect.acronym 'USPS'
  inflect.acronym 'BPS'
  inflect.acronym 'ABC'
  inflect.acronym 'ExCom'
  inflect.acronym 'VSC'
  inflect.acronym 'GPS'
  inflect.acronym 'VHF'
  inflect.acronym 'DSC'
  inflect.acronym 'AIS'
  inflect.acronym 'PCOC'
  inflect.acronym 'VHF DSC'
  inflect.acronym 'CPR AED'
  inflect.acronym 'OTW'
end
