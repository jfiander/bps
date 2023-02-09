# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BridgeOffice, type: :model do
  let!(:commander) { FactoryBot.create(:bridge_office, office: 'commander') }
  let!(:executive) { FactoryBot.create(:bridge_office, office: 'executive') }
  let!(:educational) { FactoryBot.create(:bridge_office, office: 'educational') }
  let!(:administrative) { FactoryBot.create(:bridge_office, office: 'administrative') }
  let!(:asst_educational) { FactoryBot.create(:bridge_office, office: 'asst_educational') }
  let!(:asst_secretary) { FactoryBot.create(:bridge_office, office: 'asst_secretary') }

  describe 'titles' do
    it 'adds officer when appropriate' do
      expect(educational.title).to eql('Educational Officer')
    end

    it 'does not add officer when inappropriate' do
      expect(commander.title).to eql('Commander')
    end

    it 'adds assistant when appropriate' do
      expect(asst_secretary.title).to eql('Assistant Secretary')
    end
  end

  it 'returns the correct hash from preload' do
    expect(described_class.preload).to eql(
      commander.user_id => 'commander',
      executive.user_id => 'executive',
      educational.user_id => 'educational',
      administrative.user_id => 'administrative',
      asst_educational.user_id => 'asst_educational',
      asst_secretary.user_id => 'asst_secretary'
    )
  end

  it 'returns the correct department' do
    expect(educational.department).to eql('Educational')
  end

  it 'selects the correct email' do
    expect(educational.email).to eql('seo@bpsd9.org')
  end

  it 'rejects invalid offices' do
    invalid = FactoryBot.build(:bridge_office, office: 'invalid')
    expect(invalid.valid?).to be(false)
    expect(invalid.errors.messages.to_h).to eql(office: ['must be in BridgeOffice.departments(assistants: true)'])
  end

  describe 'advance' do
    def officer(department)
      described_class.find_by(office: department).user
    end

    context 'without an AO id' do
      it 'updates the commander' do
        expect { described_class.advance }.to change { officer('commander') }
          .from(commander.user)
          .to(executive.user)
      end

      it 'updates the XO' do
        expect { described_class.advance }.to change { officer('executive') }
          .from(executive.user)
          .to(administrative.user)
      end

      it 'updates the AO' do
        expect { described_class.advance }.to change { officer('administrative') }
          .from(administrative.user)
          .to(nil)
      end
    end

    context 'with an AO id' do
      let(:new_ao) { FactoryBot.create(:user) }

      it 'updates the commander' do
        expect { described_class.advance(new_ao.id) }.to change { officer('commander') }
          .from(commander.user)
          .to(executive.user)
      end

      it 'updates the XO' do
        expect { described_class.advance(new_ao.id) }.to change { officer('executive') }
          .from(executive.user)
          .to(administrative.user)
      end

      it 'updates the AO' do
        expect { described_class.advance(new_ao.id) }.to change { officer('administrative') }
          .from(administrative.user)
          .to(new_ao)
      end
    end
  end

  describe 'mail_all' do
    it 'generates the correct mailing list' do
      expect(described_class.mail_all.sort).to eql([
        commander.user.email,
        executive.user.email,
        educational.user.email,
        administrative.user.email
      ].sort)
    end

    it 'generates the correct mailing list including assistants' do
      expect(described_class.mail_all(include_asst: true).sort).to eql([
        commander.user.email,
        executive.user.email,
        educational.user.email,
        administrative.user.email,
        asst_educational.user.email,
        asst_secretary.user.email
      ].sort)
    end
  end
end
