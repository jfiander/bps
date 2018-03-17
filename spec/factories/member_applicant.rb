FactoryBot.define do
  factory :member_applicant do
    association :member_application
    primary false
    member_type 'Active'
    first_name ''
    middle_name ''
    last_name ''
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
  end
end
