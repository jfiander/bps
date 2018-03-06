FactoryBot.define do
  factory :course_include do
    association :course
    sequence(:text) { |n| "Include #{n}" }
  end
end
