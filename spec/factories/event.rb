# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    association :event_type
    start_at Time.now + 1.week
    cutoff_at Time.now + 2.weeks
    expires_at Time.now + 3.weeks
    show_in_catalog false
    length_h 2
    repeat_pattern 'WEEKLY'

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
      allow_public_registrations false
    end
  end
end
