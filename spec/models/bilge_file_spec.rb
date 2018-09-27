# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BilgeFile, type: :model do
  it 'should have the correct number of issues' do
    expect(BilgeFile.issues.count).to eql(11)
  end

  it 'should return the correct issue' do
    bilge = FactoryBot.create(
      :bilge_file,
      year: 2017, month: 5, file: File.open(test_image(200, 500), 'r')
    )

    expect(bilge.issue).to eql('May')
  end
end
