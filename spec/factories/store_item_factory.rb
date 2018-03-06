FactoryBot.define do
  factory :store_item do
    name { SecureRandom.hex(4) }
    price 10.00
  end
end
