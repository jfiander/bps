# frozen_string_literal: true

FactoryBot.define do
  factory :standing_committee_office do
    committee_name { 'executive' }
    association :user
    chair { false }
    term_start_at { Time.zone.today }
    term_length { 1 }
  end
end
