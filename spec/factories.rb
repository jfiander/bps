FactoryBot.define do
  factory :photo do
    album_id 1
  end
  factory :album do
    name "MyString"
  end
  factory :role do
    sequence(:name) { |n| "This is example #{n}." }
  end

  factory :user do
    sequence(:email) { |n| "example-#{n}@example.com" }
    password SecureRandom.hex(16)
  end

  factory :user_role do
    association :user
    association :role
  end
end
