# frozen_string_literal: true

FactoryBot.define do
  factory :roster_award_recipient, class: Roster::AwardRecipient do
    award_name 'Noteworthy'
    year '2018-01-01'
    user_id nil
    name 'John Doe'
    photo ''
  end
end
