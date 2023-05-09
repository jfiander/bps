# frozen_string_literal: true

FactoryBot.define do
  factory :event_option do
    association :event_selection
  end
end
