# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Voting::Ballot, type: :model do
  subject(:ballot) { FactoryBot.create(:ballot, election: election) }

  let!(:election) { FactoryBot.create(:election) }
  let(:new_election) { FactoryBot.create(:election) }
  let(:new_user) { FactoryBot.create(:user) }

  before { allow(election).to receive(:open?).and_return true }

  describe '#protect_changes' do
    it 'cannot change election', :aggregate_failures do
      ballot.election = new_election

      expect(ballot).not_to be_valid
      expect(ballot.errors.messages).to include(election_id: ['cannot be modified'])
    end

    it 'cannot change user', :aggregate_failures do
      ballot.user = new_user

      expect(ballot).not_to be_valid
      expect(ballot.errors.messages).to include(user_id: ['cannot be modified'])
    end
  end

  describe '#restrict_user' do
    subject(:ballot) { FactoryBot.build(:ballot, election: election, user: user) }

    context 'with a general member' do
      let(:user) { FactoryBot.create(:user) }

      it { is_expected.to be_valid }

      it 'is invalid when restricted' do
        election.restriction = 'executive'

        expect(ballot).not_to be_valid
      end
    end

    context 'with an ExCom member' do
      let(:user) { FactoryBot.create(:standing_committee_office, committee_name: 'executive').user }

      it { is_expected.to be_valid }

      it 'is valid when restricted' do
        election.restriction = 'executive'

        expect(ballot).to be_valid
      end
    end
  end

  describe '#yes_no?' do
    it 'raises an error for a non-single election' do
      election.style = 'preference'

      expect { ballot.yes_no? }.to raise_error(RuntimeError, 'Can only use yes_no? for single votes')
    end

    context 'with a Yes vote' do
      before { ballot.votes.create!(selection: 'Yes') }

      it { is_expected.to be_yes_no }
    end

    context 'with a No vote' do
      before { ballot.votes.create!(selection: 'No') }

      it { is_expected.not_to be_yes_no }
    end
  end
end
