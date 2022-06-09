# frozen_string_literal: true

FactoryBot.define do
  factory :glyc_member do
    sequence(:email) { |n| "someone.#{n}@example.com" }
  end
end
