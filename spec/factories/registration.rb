# frozen_string_literal: true

FactoryBot.define do
  factory :registration do
    association :event

    trait :with_user do
      association :user
    end

    trait :with_email do
      email { "#{SecureRandom.hex(8)}@example.com" }
    end

    trait :event do
      before(:create) do |reg|
        event_type = FactoryBot.create(:event_type, event_category: 'meeting')
        reg.event = FactoryBot.create(:event, event_type: event_type)
      end
    end

    factory :event_registration, traits: [:event]
  end
end
