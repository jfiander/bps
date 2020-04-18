# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnouncementFile, type: :model do
  before do
    @announcement = FactoryBot.create(
      :announcement_file, title: 'An Announcement', file: File.open(test_image(200, 500), 'r')
    )
  end

  it 'returns a valid link' do
    expect(@announcement.link).to match(
      %r{\Ahttps://files.development.bpsd9.org/uploaded/announcement_files/\d+/test_image.jpg\?}
    )
  end

  it 'returns a valid permalink' do
    expect(@announcement.link(true)).to match(%r{\A/announcement/\d+$})
  end

  it 'does not return an error on invalidate!' do
    expect { @announcement.invalidate! }.not_to raise_error
  end
end
