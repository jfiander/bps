# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    association :event_type
    start_at { 1.week.from_now }
    cutoff_at { 2.weeks.from_now }
    expires_at { 3.weeks.from_now }
    show_in_catalog { false }
    length_h { 2 }
    repeat_pattern { 'WEEKLY' }

    trait :with_instructor do
      after(:create) do |event|
        event.assign_instructor(FactoryBot.create(:user))
      end
    end

    trait :with_prereq do
      after(:create) do |event|
        event.update(prereq: FactoryBot.create(:event_type))
      end
    end

    trait :with_topics do
      after(:create) do |event|
        FactoryBot.create_list(:course_topic, 3, course: event)
      end
    end

    trait :with_includes do
      after(:create) do |event|
        FactoryBot.create_list(:course_include, 3, course: event)
      end
    end

    trait :not_public_registerable do
      allow_public_registrations { false }
    end
  end
end
