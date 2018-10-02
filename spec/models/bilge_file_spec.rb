# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BilgeFile, type: :model do
  it 'should have the correct number of issues' do
    expect(BilgeFile.issues.count).to eql(11)
  end

  describe 'issues' do
    before(:each) do
      @bilge = FactoryBot.create(
        :bilge_file,
        year: 2017, month: 9, file: File.open(test_image(200, 500), 'r')
      )
    end

    it 'should return the correct issue' do
      expect(@bilge.issue).to eql('Sep')
    end

    it 'should return the correct full_issue' do
      expect(@bilge.full_issue).to eql('2017 Sep')
    end

    it 'should return a valid link' do
      # This link is not signed in tests
      expect(@bilge.link).to match(
        %r{https://bilge.development.bpsd9.org/\d+/Bilge_Chatter.pdf}
      )
    end
  end
end
