# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MinutesFile, type: :model do
  it 'should have the correct number of issues' do
    expect(MinutesFile.issues.count).to eql(10)
  end

  it 'should return the correct issue' do
    minutes = FactoryBot.create(
      :minutes_file,
      year: 2017, month: 9, file: File.open(test_image(200, 500), 'r')
    )

    expect(minutes.issue).to eql('Sep')
  end
end
