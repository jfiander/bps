# frozen_string_literal: true

FactoryBot.define do
  factory :persistent_api_token do
    association :user
  end
end
