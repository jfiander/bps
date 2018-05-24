# frozen_string_literal: true

FactoryBot.define do
  factory :course_topic do
    association :course
    sequence(:text) { |n| "Topic #{n}" }
  end
end
