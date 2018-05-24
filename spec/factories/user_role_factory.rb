# frozen_string_literal: true

FactoryBot.define do
  factory :user_role do
    association :user
    association :role
  end
end
