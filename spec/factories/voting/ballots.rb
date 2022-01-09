# frozen_string_literal: true

FactoryBot.define do
  factory :ballot, class: 'Voting::Ballot' do
    association :election
    association :user
  end
end
