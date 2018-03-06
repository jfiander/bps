FactoryBot.define do
  factory :item_request do
    association :store_item
    association :user
  end
end
