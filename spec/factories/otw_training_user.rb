# frozen_string_literal: true

FactoryBot.define do
  factory :otw_training_user do
    association :otw_training
    association :user
  end
end
