# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BilgeFile, type: :model do
  before do
    @bilge = FactoryBot.create(:bilge_file, year: 2017, month: 9, file: File.open(test_image(200, 500), 'r'))
  end

  it 'has the correct number of issues' do
    expect(BilgeFile.issues.count).to be(11)
  end

  describe 'issues' do
    it 'returns the correct issue' do
      expect(@bilge.issue).to eql('Sep')
    end

    it 'returns the correct full_issue' do
      expect(@bilge.full_issue).to eql('2017 Sep')
    end
  end

  describe 'links' do
    it 'returns a valid link' do
      expect(@bilge.link).to match(%r{\Ahttps://bilge.development.bpsd9.org/\d+/Bilge_Chatter.pdf\?})
    end

    it 'returns a valid permalink' do
      expect(@bilge.link(true)).to match(%r{\A/bilge/\d+/\d+$})
    end
  end

  it 'does not return an error on invalidate!' do
    expect { @bilge.invalidate! }.not_to raise_error
  end
end
