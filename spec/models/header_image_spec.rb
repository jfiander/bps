# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FloatPlan, type: :model do
  describe 'pick' do
    before(:each) do
      FactoryBot.create_list(:header_image, 5, file: File.new(test_image(1500, 500)))
      @pick = FactoryBot.create(:header_image, file: File.new(test_image(1500, 500)))
      @picks = []
    end

    it 'should pick the selected image, if specified' do
      20.times { @picks << HeaderImage.pick(@pick.id) }
      expect(@picks.uniq.count).to eql(1)
    end

    it 'should pick multiple images, if not specified' do
      20.times { @picks << HeaderImage.pick }
      expect(@picks.uniq.count).to be > 1
    end
  end

  describe 'valid image dimensions' do
    it 'should reject if too wide' do
      header = FactoryBot.build(:header_image, file: File.new(test_image(1500, 300)))
      expect(header.validate).to be(false)
      expect(header.errors.messages).to eql(file: ['aspect ratio > 3.5:1 (make it narrower)'])
    end

    it 'should reject if too narrow' do
      header = FactoryBot.build(:header_image, file: File.new(test_image(1000, 500)))
      expect(header.validate).to be(false)
      expect(header.errors.messages).to eql(file: ['aspect ratio < 2.75:1 (make it wider)'])
    end

    it 'should reject if too small' do
      header = FactoryBot.build(:header_image, file: File.new(test_image(500, 150)))
      expect(header.validate).to be(false)
      expect(header.errors.messages).to eql(file: ['must be at least 1000px wide'])
    end

    it 'should accept if correctly sized' do
      header = FactoryBot.build(:header_image, file: File.new(test_image(1500, 500)))
      expect(header.validate).to be(true)
      expect(header.errors.messages).to be_blank
    end
  end
end
