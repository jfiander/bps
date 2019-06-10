# frozen_string_literal: true

FactoryBot.define do
  factory :roster_past_commander, class: Roster::PastCommander do
    year { '2018-01-01' }
    user_id { nil }
    name { 'John Doe' }
    deceased { false }
    comment { nil }
  end
end
