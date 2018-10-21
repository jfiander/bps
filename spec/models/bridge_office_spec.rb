# frozen_string_literal: true

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

  it 'should return the correct hash from preload' do
    cdr = FactoryBot.create(:user)
    FactoryBot.create(:bridge_office, user: cdr, office: 'commander')
    seo = FactoryBot.create(:user)
    FactoryBot.create(:bridge_office, user: seo, office: 'educational')
    asec = FactoryBot.create(:user)
    FactoryBot.create(:bridge_office, user: asec, office: 'asst_secretary')

    expect(BridgeOffice.preload).to eql(cdr.id => 'commander', seo.id => 'educational', asec.id => 'asst_secretary')
  end

  it 'should return the correct department' do
    @bridge = FactoryBot.create(:bridge_office, office: 'educational')
    expect(@bridge.department).to eql('Educational')
  end

  it 'should select the correct email' do
    @bridge = FactoryBot.create(:bridge_office, office: 'educational')
    expect(@bridge.email).to eql('seo@bpsd9.org')
  end

  it 'should reject invalid offices' do
    @bridge = FactoryBot.build(:bridge_office, office: 'invalid')
    expect(@bridge.valid?).to be(false)
    expect(@bridge.errors.messages).to eql(office: ['must be in BridgeOffice.departments(assistants: true)'])
  end
end
