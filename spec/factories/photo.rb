# frozen_string_literal: true

FactoryBot.define do
  factory :photo do
    album_id { 1 }

    before(:create) do |photo|
      photo.photo_file = File.open(test_image(500, 500), 'r')
    end
  end
end
