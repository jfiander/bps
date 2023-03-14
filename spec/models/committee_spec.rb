# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Committee do
  describe 'search names' do
    it 'preserves valid names' do
      committee = create(:committee)
      expect(committee.search_name).to eql('rendezvous')
    end

    it 'downcases everything' do
      committee = create(:committee, name: 'Meetings')
      expect(committee.search_name).to eql('meetings')
    end

    it 'replaces spaces with underscores' do
      committee = create(:committee, name: 'something else')
      expect(committee.search_name).to eql('something_else')
    end

    it 'removes quotation marks' do
      committee = create(:committee, name: "Ship's Store")
      expect(committee.search_name).to eql('ships_store')
    end

    it 'removes an assistant prefix' do
      committee = create(:committee, name: 'Assistant Something')
      expect(committee.search_name).to eql('something')
    end
  end

  describe 'display names' do
    it 'does not modify a simple name' do
      committee = create(:committee)
      expect(committee.display_name).to eql(committee.name)
    end

    it 'modifies a multi-line name' do
      committee = create(:committee, name: 'Something//With a subtitle')
      expect(committee.display_name).to eql('Something<small><br>&nbsp;&nbsp;With a subtitle</small>')
    end
  end

  describe 'mail_all' do
    it 'gets the emails for the assigned users' do
      committee = create(:committee, department: :executive, name: 'This One')
      create(:committee, name: 'Not That One')

      expect(described_class.mail_all(:executive, 'This One')).to eql([committee.user.email])
    end
  end
end
