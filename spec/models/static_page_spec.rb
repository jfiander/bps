# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StaticPage, type: :model do
  describe 'class methods' do
    it 'should return a list of names' do
      FactoryBot.create_list(:static_page, 3)
      expect(StaticPage.names).to eql(StaticPage.all.map(&:name))
    end
  end

  describe 'titles' do
    it 'should correctly format the About title' do
      page = FactoryBot.create(:static_page, name: 'about')
      expect(page.title).to eql('About Us')
    end

    it 'should correctly format the Join title' do
      page = FactoryBot.create(:static_page, name: 'join')
      expect(page.title).to eql('Join Us')
    end

    it 'should correctly format the Civic title' do
      page = FactoryBot.create(:static_page, name: 'civic')
      expect(page.title).to eql('Civic Services')
    end

    it 'should correctly format the VSC title' do
      page = FactoryBot.create(:static_page, name: 'vsc')
      expect(page.title).to eql('Vessel Safety Check')
    end

    it 'should correctly format other titles' do
      page = FactoryBot.create(:static_page)
      expect(page.title).to eql(page.name.titleize)
    end
  end

  it 'should have the correct versions path' do
    page = FactoryBot.create(:static_page)

    expect(page.versions_path).to eql('/versions/StaticPage/1')
  end
end
