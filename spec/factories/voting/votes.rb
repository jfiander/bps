# frozen_string_literal: true

FactoryBot.define do
  factory :vote, class: 'Voting::Vote' do
    association :ballot
  end
end
