# frozen_string_literal: true

FactoryBot.define do
  factory :item_request do
    association :store_item
    association :user
  end
end
