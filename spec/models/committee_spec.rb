# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Committee, type: :model do
  describe 'search names' do
    it 'should preserve valid names' do
      @committee = FactoryBot.create(:committee)
      expect(@committee.search_name).to eql('rendezvous')
    end

    it 'should downcase everything' do
      @committee = FactoryBot.create(:committee, name: 'Meetings')
      expect(@committee.search_name).to eql('meetings')
    end

    it 'should replace spaces with underscores' do
      @committee = FactoryBot.create(:committee, name: 'something else')
      expect(@committee.search_name).to eql('something_else')
    end

    it 'should remove quotation marks' do
      @committee = FactoryBot.create(:committee, name: "Ship's Store")
      expect(@committee.search_name).to eql('ships_store')
    end

    it 'should remove an assistant prefix' do
      @committee = FactoryBot.create(:committee, name: 'Assistant Something')
      expect(@committee.search_name).to eql('something')
    end
  end

  describe 'display names' do
    it 'should not modify a simple name' do
      @committee = FactoryBot.create(:committee)
      expect(@committee.display_name).to eql(@committee.name)
    end

    it 'should not modify a simple name' do
      @committee = FactoryBot.create(:committee, name: 'Something//With a subtitle')
      expect(@committee.display_name).to eql('Something<small><br>&nbsp;&nbsp;With a subtitle</small>')
    end
  end
end
