FactoryBot.define do
  factory :event_instructor do
    association :event
    association :user
  end
end
