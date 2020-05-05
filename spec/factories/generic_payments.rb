# frozen_string_literal: true

FactoryBot.define do
  factory :generic_payment do
    description { 'Generic Payment' }
    amount { 1 }
  end
end
