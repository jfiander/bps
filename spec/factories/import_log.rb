# frozen_string_literal: true

FactoryBot.define do
  factory :import_log do
    json '{:created=>[], :updated=>{}, :completions=>[], :families=>{}, :locked=>:skipped}'
  end
end
