# frozen_string_literal: true

FactoryBot.define do
  factory :course_completion do
    association :user
    course_key { 'SE' }
    date { Time.zone.today.beginning_of_year }
  end
end
