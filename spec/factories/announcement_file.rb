# frozen_string_literal: true

FactoryBot.define do
  factory :announcement_file do
    title { |n| "Announcement #{n}" }
  end
end
