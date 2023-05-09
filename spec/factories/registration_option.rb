# frozen_string_literal: true

FactoryBot.define do
  factory :registration_option do
    association :registration
    association :event_option
  end
end
