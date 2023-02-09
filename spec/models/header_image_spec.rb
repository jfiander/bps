# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HeaderImage, type: :model do
  let(:demo_image) { File.new(test_image(1500, 500)) }

  describe 'pick' do
    before do
      FactoryBot.create_list(:header_image, 5, file: demo_image)
      @pick = FactoryBot.create(:header_image, file: demo_image)
      @picks = []
    end

    it 'picks the selected image, if specified' do
      20.times { @picks << described_class.pick(@pick.id) }
      expect(@picks.uniq.count).to be(1)
    end

    it 'picks multiple images, if not specified' do
      20.times { @picks << described_class.pick }
      expect(@picks.uniq.count).to be > 1
    end
  end

  describe 'valid image dimensions' do
    it 'rejects if too wide' do
      header = FactoryBot.build(:header_image, file: File.new(test_image(1500, 300)))
      expect(header.validate).to be(false)
      expect(header.errors.messages.to_h).to eql(file: ['aspect ratio > 3.5:1 (make it narrower)'])
    end

    it 'rejects if too narrow' do
      header = FactoryBot.build(:header_image, file: File.new(test_image(1000, 500)))
      expect(header.validate).to be(false)
      expect(header.errors.messages.to_h).to eql(file: ['aspect ratio < 2.75:1 (make it wider)'])
    end

    it 'rejects if too small' do
      header = FactoryBot.build(:header_image, file: File.new(test_image(500, 150)))
      expect(header.validate).to be(false)
      expect(header.errors.messages.to_h).to eql(file: ['must be at least 750px wide'])
    end

    it 'accepts if correctly sized' do
      header = FactoryBot.build(:header_image, file: demo_image)
      expect(header.validate).to be(true)
      expect(header.errors.messages.to_h).to be_blank
    end
  end

  describe 'dimensions' do
    let(:header) do
      FactoryBot.create(
        :header_image, file: demo_image, width: 1500, height: 500
      )
    end

    it 'generates valid dimensions' do
      expect(header.dimensions).to eq('1500x500')
    end

    it 'generates a valid ratio' do
      expect(header.ratio).to eq(3.0)
    end
  end
end
