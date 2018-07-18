# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Album, type: :model do
  it 'should use the first photo as a cover' do
    album = FactoryBot.create(:album)
    FactoryBot.create(:photo, album: album)
    FactoryBot.create(:photo, album: album)

    expect(album.cover).to eql(album.photos.first)
  end
end
