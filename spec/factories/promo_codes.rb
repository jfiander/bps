# frozen_string_literal: true

FactoryBot.define do
  factory :promo_code do
    code { SecureRandom.hex(8) }
    valid_at { nil }
    expires_at { nil }
  end
end
