# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    address do
      "#{SecureRandom.hex(8)}\n#{SecureRandom.hex(8)}\n#{SecureRandom.hex(8)}"
    end
    map_link 'https://maps.example.com'
    details 'address details'
    picture { }
  end
end
