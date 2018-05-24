# frozen_string_literal: true

FactoryBot.define do
  factory :member_applicant do
    association :member_application
    primary false
    member_type 'Active'
    first_name 'John'
    middle_name ''
    last_name 'Doe'
    dob ''
    gender ''
    address_1 ''
    address_2 ''
    city ''
    state ''
    zip ''
    phone_h ''
    phone_c ''
    phone_w ''
    fax ''
    sequence(:email) { |n| "example-#{n}@example.com" }
    sea_scout false
    sig_other_name ''
    boat_type ''
    boat_length ''
    boat_name ''
    previous_certificate ''

    trait :primary do
      primary true
      address_1 '123 ABC St'
      city 'City'
      state 'ST'
      zip '12345'
      phone_h '1234567890'
      boat_type 'None'
    end

    factory :primary_applicant, traits: [:primary]
  end
end
