# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MinutesFile, type: :model do
  it 'should have the correct number of issues' do
    expect(MinutesFile.issues.count).to eql(10)
  end

  describe 'issues' do
    before(:each) do
      @minutes = FactoryBot.create(
        :minutes_file,
        year: 2017, month: 9, file: File.open(test_image(200, 500), 'r')
      )
    end

    it 'should return the correct issue' do
      expect(@minutes.issue).to eql('Sep')
    end

    it 'should return the correct full_issue' do
      expect(@minutes.full_issue).to eql('2017 Sep')
    end

    it 'should return a valid link' do
      # This link is not signed in tests
      expect(@minutes.link).to match(
        %r{https://files.development.bpsd9.org/uploaded/minutes_files/\d+/test_image.jpg}
      )
    end
  end
end
