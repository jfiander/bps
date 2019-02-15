# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location, type: :model do
  before(:each) do
    @location = FactoryBot.create(:location)
  end

  describe 'searchable' do
    it 'should return a hash' do
      expect(Location.searchable).to be_a(Hash)
    end

    it 'should have integer keys' do
      expect(Location.searchable.keys.all? { |k| k.is_a?(Integer) }).to be(true)
    end
  end

  describe 'map_links' do
    it 'should store a valid http link as provided' do
      @location.update(map_link: 'http://maps.example.com')
      expect(@location.map_link).to eql('http://maps.example.com')
    end

    it 'should store a valid https link as provided' do
      @location.update(map_link: 'https://maps.example.com')
      expect(@location.map_link).to eql('https://maps.example.com')
    end

    it 'should prefix a bare link with http' do
      @location.update(map_link: 'maps.example.com')
      expect(@location.map_link).to eql('http://maps.example.com')
    end

    it 'should reject invalid URLs' do
      @location.map_link = 'blah blah'
      expect(@location.valid?).to be(false)
      expect(@location.errors.messages).to eql(map_link: ['is not a valid URL.'])
    end
  end

  describe 'display' do
    it 'should return the default' do
      @location.address = nil
      expect(@location.display).to eql(id: 0, address: 'TBD')
    end

    it 'should return the display hash' do
      expect(@location.display).to eql(
        id: @location.id,
        name: @location.name,
        address: @location.address,
        favorite: @location.favorite,
        price_comment: @location.price_comment,
        map_link: @location.map_link,
        details: @location.details,
        picture: @location.picture,
        price_comment: nil
      )
    end
  end

  it 'should return the correct one-line address' do
    location = FactoryBot.create(:location, address: "123\n456\n789")
    expect(location.one_line).to eql('123, 456, 789')
  end
end
