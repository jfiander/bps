FactoryBot.define do
  factory :registration do
    association :event

    trait :with_user do
      association :user
    end

    trait :with_email do
      email "#{SecureRandom.hex(8)}@example.com"
    end
  end
end
