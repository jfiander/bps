FactoryBot.define do
  factory :payment do
    parent_type 'Registration'
    parent_id 1
    transaction_id { SecureRandom.hex(8) }
  end
end
