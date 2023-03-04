# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Album do
  let(:album) do
    create(:album).tap do |a|
      create(:photo, album: a)
      create(:photo, album: a)
    end
  end

  it 'uses the first photo as a cover' do
    expect(album.cover).to eql(album.photos.first)
  end

  it 'uses the first photo as a cover with a non-existent cover_id set' do
    album.update(cover_id: -1)

    expect(album.cover).to eql(album.photos.first)
  end

  it 'uses a specified cover photo' do
    photo = album.photos.last
    album.update(cover_id: photo.id)

    expect(album.cover).to eql(photo)
  end
end
