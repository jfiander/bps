# frozen_string_literal: true

FactoryBot.define do
  factory :bridge_office do
    office { 'commander' }
    association :user
  end
end
