FactoryBot.define do
  factory :user do
    sequence(:first_name) { |n| "First_#{n}" }
    sequence(:last_name) { |n| "Last_#{n}" }
    grade 'AP'
    email { "example-#{SecureRandom.hex(8)}@example.com" }
    certificate { SecureRandom.hex(4) }
    password { SecureRandom.hex(16) }

    trait :placeholder_email do
      email { "nobody-#{SecureRandom.hex(8)}@bpsd9.org" }
    end
  end
end
