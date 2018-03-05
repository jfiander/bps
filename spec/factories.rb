FactoryBot.define do
  factory :header_image do
    image_file ''
  end

  factory :photo do
    album_id 1
  end

  factory :album do
    name 'Test Album'
  end

  factory :role do
    sequence(:name) { |n| "This is example #{n}." }
  end

  factory :user do
    email { "example-#{SecureRandom.hex(8)}@example.com" }
    password SecureRandom.hex(16)

    trait :placeholder_email do
      email { "nobody-#{SecureRandom.hex(8)}@bpsd9.org" }
    end
  end

  factory :event do
    association :event_type
    start_at Time.now + 1.week
    show_in_catalog false

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
  end

  factory :event_type do
    event_category 'public'
    title "America's Boating Course"
  end

  factory :event_instructor do
    association :event
    association :user
  end

  factory :course_topic do
    association :course
    sequence(:text) { |n| "Topic #{n}" }
  end

  factory :course_include do
    association :course
    sequence(:text) { |n| "Include #{n}" }
  end

  factory :user_role do
    association :user
    association :role
  end

  factory :bridge_office do
    office 'commander'
    association :user
  end

  factory :committee do
    name 'rendezvous'
    department 'administrative'
    association :user
  end

  factory :location do
    address { "#{SecureRandom.hex(8)}\n#{SecureRandom.hex(8)}\n#{SecureRandom.hex(8)}" }
    map_link 'https://maps.example.com'
    details 'address details'
    picture {}
  end

  factory :store_item do
    name { SecureRandom.hex(4) }
    price 10.00
  end

  factory :item_request do
    association :store_item
    association :user
  end

  factory :static_page do
    sequence(:name) { |n| "test_#{n}" }
    markdown 'Just some text'
  end
end
