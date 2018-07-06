# frozen_string_literal: true

FactoryBot.define do
  factory :course_completion do
    association :user
    course_key 'SE'
    date Date.today.beginning_of_year
  end
end
