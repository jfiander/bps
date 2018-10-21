# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FloatPlan, type: :model do
  it 'should reject a too-wide image' do
    header = HeaderImage.new(file: File.new(test_image(1500, 300)))
    expect(header.validate).to be(false)
    expect(header.errors.messages).to eql(file: ['aspect ratio > 3.5:1 (make it narrower)'])
  end

  it 'should reject a too-narrow image' do
    header = HeaderImage.new(file: File.new(test_image(1000, 500)))
    expect(header.validate).to be(false)
    expect(header.errors.messages).to eql(file: ['aspect ratio < 2.75:1 (make it wider)'])
  end

  it 'should reject a too-small image' do
    header = HeaderImage.new(file: File.new(test_image(500, 150)))
    expect(header.validate).to be(false)
    expect(header.errors.messages).to eql(file: ['must be at least 1000px wide'])
  end

  it 'should accept a correctly-sized image' do
    header = HeaderImage.new(file: File.new(test_image(1500, 500)))
    expect(header.validate).to be(true)
    expect(header.errors.messages).to be_blank
  end
end
