# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BridgeOffice, type: :model do
  describe 'titles' do
    it 'adds officer when appropriate' do
      @bridge = FactoryBot.create(:bridge_office, office: 'educational')
      expect(@bridge.title).to eql('Educational Officer')
    end

    it 'does not add officer when inappropriate' do
      @bridge = FactoryBot.create(:bridge_office, office: 'commander')
      expect(@bridge.title).to eql('Commander')
    end

    it 'adds assistant when appropriate' do
      @bridge = FactoryBot.create(:bridge_office, office: 'asst_secretary')
      expect(@bridge.title).to eql('Assistant Secretary')
    end
  end

  it 'returns the correct hash from preload' do
    cdr = FactoryBot.create(:user)
    FactoryBot.create(:bridge_office, user: cdr, office: 'commander')
    seo = FactoryBot.create(:user)
    FactoryBot.create(:bridge_office, user: seo, office: 'educational')
    asec = FactoryBot.create(:user)
    FactoryBot.create(:bridge_office, user: asec, office: 'asst_secretary')

    expect(BridgeOffice.preload).to eql(cdr.id => 'commander', seo.id => 'educational', asec.id => 'asst_secretary')
  end

  it 'returns the correct department' do
    @bridge = FactoryBot.create(:bridge_office, office: 'educational')
    expect(@bridge.department).to eql('Educational')
  end

  it 'selects the correct email' do
    @bridge = FactoryBot.create(:bridge_office, office: 'educational')
    expect(@bridge.email).to eql('seo@bpsd9.org')
  end

  it 'rejects invalid offices' do
    @bridge = FactoryBot.build(:bridge_office, office: 'invalid')
    expect(@bridge.valid?).to be(false)
    expect(@bridge.errors.messages).to eql(office: ['must be in BridgeOffice.departments(assistants: true)'])
  end

  describe 'advance' do
    before do
      @cdr = FactoryBot.create(:bridge_office, office: 'commander').user
      @xo = FactoryBot.create(:bridge_office, office: 'executive').user
      @ao = FactoryBot.create(:bridge_office, office: 'administrative').user
    end

    it 'moves officers without an AO id' do
      BridgeOffice.advance

      expect(BridgeOffice.find_by(office: 'commander').user).to eql(@xo)
      expect(BridgeOffice.find_by(office: 'executive').user).to eql(@ao)
      expect(BridgeOffice.find_by(office: 'administrative').user).to be_nil
    end

    it 'moves officers with an AO id' do
      new_ao = FactoryBot.create(:user)
      BridgeOffice.advance(new_ao.id)

      expect(BridgeOffice.find_by(office: 'commander').user).to eql(@xo)
      expect(BridgeOffice.find_by(office: 'executive').user).to eql(@ao)
      expect(BridgeOffice.find_by(office: 'administrative').user).to eql(new_ao)
    end
  end

  describe 'mail_all' do
    before do
      @commander = FactoryBot.create(:bridge_office, office: 'commander')
      @seo = FactoryBot.create(:bridge_office, office: 'educational')
      @aseo = FactoryBot.create(:bridge_office, office: 'asst_secretary')
    end

    it 'generates the correct mailing list' do
      expect(BridgeOffice.mail_all.sort).to eql([@commander.user.email, @seo.user.email].sort)
    end

    it 'generates the correct mailing list including assistants' do
      expect(BridgeOffice.mail_all(include_asst: true).sort).to eql(
        [@commander.user.email, @seo.user.email, @aseo.user.email].sort
      )
    end
  end
end
