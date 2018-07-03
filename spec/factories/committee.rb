# frozen_string_literal: true

FactoryBot.define do
  factory :committee do
    name 'rendezvous'
    department 'administrative'
    association :user
  end
end
