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
    email "example-#{SecureRandom.hex(8)}@example.com"
    password SecureRandom.hex(16)
  end

  factory :event do
    association :event_type
    start_at Time.now + 1.week
  end

  factory :event_type do
    event_category 'public'
    title "America's Boating Course"
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
    address "#{SecureRandom.hex(8)}\n#{SecureRandom.hex(8)}\n#{SecureRandom.hex(8)}"
    map_link 'https://maps.example.com'
    details 'address details'
    picture {}
  end
end
