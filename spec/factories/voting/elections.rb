# frozen_string_literal: true

FactoryBot.define do
  factory :election, class: 'Voting::Election' do
    style { 'single' }
  end
end
