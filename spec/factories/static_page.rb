# frozen_string_literal: true

FactoryBot.define do
  factory :static_page do
    sequence(:name) { |n| "test_#{n}" }
    markdown 'Just some text'
  end
end
