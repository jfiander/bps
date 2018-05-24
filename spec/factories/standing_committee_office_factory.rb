# frozen_string_literal: true

FactoryBot.define do
  factory :standing_committee_office do
    committee_name 'executive'
    association :user
    chair false
  end
end
