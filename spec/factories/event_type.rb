# frozen_string_literal: true

FactoryBot.define do
  factory :event_type do
    event_category { 'public' }
    title { "america's_boating_course" }
  end
end
