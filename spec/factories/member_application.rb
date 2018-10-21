# frozen_string_literal: true

FactoryBot.define do
  factory :member_application do
    trait :with_primary do
      before(:create) do |app|
        primary = FactoryBot.build(:primary_applicant, member_application: app)
        app.member_applicants << primary
      end
    end

    trait :with_family do
      before(:create) do |app|
        family = FactoryBot.build(:member_applicant, member_application: app)
        app.member_applicants << family
      end
    end

    trait :apprentice do
      before(:create) do |app|
        primary = FactoryBot.build(:primary_applicant, member_application: app, member_type: 'Apprentice')
        app.member_applicants << primary
      end
    end

    factory :single_application, traits: %i[with_primary]
    factory :family_application, traits: %i[with_primary with_family]
    factory :apprentice_application, traits: %i[apprentice]
  end
end
