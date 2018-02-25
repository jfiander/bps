require 'rails_helper'

RSpec.describe BridgeOffice, type: :model do
  describe 'titles' do
    it 'should add officer when appropriate' do
      @bridge = FactoryBot.create(:bridge_office, office: 'educational')
      expect(@bridge.title).to eql('Educational Officer')
    end

    it 'should not add officer when inappropriate' do
      @bridge = FactoryBot.create(:bridge_office, office: 'commander')
      expect(@bridge.title).to eql('Commander')
    end

    it 'should add assistant when appropriate' do
      @bridge = FactoryBot.create(:bridge_office, office: 'asst_secretary')
      expect(@bridge.title).to eql('Assistant Secretary')
    end
  end

  describe 'emails' do
    it 'should select the correct email' do
      @bridge = FactoryBot.create(:bridge_office, office: 'educational')
      expect(@bridge.email).to eql('seo@bpsd9.org')
    end
  end
end
