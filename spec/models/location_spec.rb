# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'map_links' do
    before(:each) do
      @location = FactoryBot.create(:location)
    end

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
  end
end
