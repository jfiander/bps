FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "This is example #{n}." }
  end
end
