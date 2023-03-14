# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StaticPage do
  describe 'class methods' do
    it 'returns a list of names' do
      create_list(:static_page, 3)
      expect(described_class.names).to eql(described_class.all.map(&:name))
    end
  end

  describe 'titles' do
    it 'correctlies format the About title' do
      page = create(:static_page, name: 'about')
      expect(page.title).to eql('About Us')
    end

    it 'correctlies format the Join title' do
      page = create(:static_page, name: 'join')
      expect(page.title).to eql('Join Us')
    end

    it 'correctlies format the Civic title' do
      page = create(:static_page, name: 'civic')
      expect(page.title).to eql('Civic Services')
    end

    it 'correctlies format the VSC title' do
      page = create(:static_page, name: 'vsc')
      expect(page.title).to eql('Vessel Safety Check')
    end

    it 'correctlies format other titles' do
      page = create(:static_page)
      expect(page.title).to eql(page.name.titleize)
    end
  end

  it 'has the correct versions path' do
    page = create(:static_page)

    expect(page.versions_path).to eql("/admin/versions/StaticPage/#{page.id}")
  end
end
