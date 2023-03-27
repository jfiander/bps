# frozen_string_literal: true

FactoryBot.define do
  factory :jobcode do
    user
    code { '31000' }
    year { 2023 }
    description { 'Commander' }
  end
end
