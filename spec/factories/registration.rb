# frozen_string_literal: true

FactoryBot.define do
  factory :registration do
    association :event

    trait :with_user do
      before(:create) do |reg|
        ur = FactoryBot.create(:user_registration, primary: true,  registration: reg, user: FactoryBot.create(:user))
        reg.user_registrations << ur
      end
    end

    trait :with_email do
      before(:create) do |reg|
        ur = FactoryBot.create(
          :user_registration, primary: true,  registration: reg, email: "#{SecureRandom.hex(8)}@example.com"
        )
        reg.user_registrations << ur
      end
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
