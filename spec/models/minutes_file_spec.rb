# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MinutesFile, type: :model do
  before do
    @minutes = FactoryBot.create(:minutes_file, year: 2017, month: 9, file: File.open(test_image(200, 500), 'r'))
  end

  it 'has the correct number of issues' do
    expect(described_class.issues.count).to be(10)
  end

  describe 'issues' do
    it 'returns the correct issue' do
      expect(@minutes.issue).to eql('Sep')
    end

    it 'returns the correct full_issue' do
      expect(@minutes.full_issue).to eql('2017 Sep')
    end
  end

  describe 'links' do
    it 'returns a valid link' do
      expect(@minutes.link).to match(
        %r{\Ahttps://files.development.bpsd9.org/uploaded/minutes_files/\d+/test_image_\w{16}.jpg\?}
      )
    end

    it 'returns a valid permalink' do
      expect(@minutes.link(permalinks: true)).to match(
        %r{\A/minutes/\d+/\d+$}
      )
    end

    it 'returns a valid excom permalink' do
      @minutes.excom = true

      expect(@minutes.link(permalinks: true)).to match(
        %r{\A/excom/\d+/\d+$}
      )
    end
  end

  it 'does not return an error on invalidate!' do
    expect { @minutes.invalidate! }.not_to raise_error
  end
end
