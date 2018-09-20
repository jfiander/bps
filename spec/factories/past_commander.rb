# frozen_string_literal: true

FactoryBot.define do
  factory :past_commander do
    year '2018-01-01'
    user_id nil
    name 'John Doe'
    deceased false
    comment nil
  end
end
