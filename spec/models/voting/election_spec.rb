# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Voting::Election, type: :model do
  subject(:election) { FactoryBot.create(:election) }

  describe '#restricted?' do
    context 'without a restriction' do
      it { is_expected.not_to be_restricted }
    end

    context 'with a restriction' do
      before { election.update(restriction: 'executive') }

      it { is_expected.to be_restricted }
    end
  end

  describe '#open?' do
    context 'without an open_at time' do
      it { is_expected.not_to be_open }
    end

    context 'with a future open_at time' do
      before { election.update(open_at: Time.now + 1.hour) }

      it { is_expected.not_to be_open }
    end

    context 'with a past open_at time' do
      before { election.update(open_at: Time.now - 1.hour) }

      context 'when closed' do
        before { allow(election).to receive(:closed?).and_return(true) }

        it { is_expected.not_to be_open }
      end

      context 'when not closed' do
        before { allow(election).to receive(:closed?).and_return(false) }

        it { is_expected.to be_open }
      end
    end
  end

  describe '#closed?' do
    context 'without a closed_at time' do
      it { is_expected.not_to be_closed }
    end

    context 'with a future closed_at time' do
      before { election.update(closed_at: Time.now + 1.hour) }

      it { is_expected.not_to be_closed }
    end

    context 'with a past closed_at time' do
      before { election.update(closed_at: Time.now - 1.hour) }

      it { is_expected.to be_closed }
    end
  end

  describe '#immediate!' do
    it 'changes the open_at and closed_at times' do
      expect { election.immediate! }.to change { [election.open_at, election.closed_at] }.from([nil, nil])
    end

    it 'creates a one-hour window' do
      election.immediate!

      expect(election.closed_at - election.open_at).to eq(1.hour)
    end
  end

  describe '#open!' do
    it 'changes the open_at time' do
      expect { election.open! }.to change { election.open_at }.from(nil)
    end
  end

  describe '#close!' do
    it 'changes the closed_at time' do
      expect { election.close! }.to change { election.closed_at }.from(nil)
    end
  end

  describe 'compliant?' do
    context 'without a restriction' do
      it 'returns nil' do
        expect(election.compliant?).to be_nil
      end
    end

    context 'with a restriction' do
      before { election.update(restriction: 'executive') }

      it { is_expected.to be_compliant }

      context 'with ExCom users present' do
        let!(:bridge) { FactoryBot.create(:bridge_office).user }
        let!(:at_large) { FactoryBot.create(:standing_committee_office, committee_name: 'executive').user }

        it { is_expected.not_to be_compliant }

        it 'is not compliant if a bridge officer has not voted' do
          allow(election).to receive(:users).and_return([at_large])

          expect(election).not_to be_compliant
        end

        it 'is not compliant if an at-large member has not voted' do
          allow(election).to receive(:users).and_return([bridge])

          expect(election).not_to be_compliant
        end

        it 'is compliant if all ExCom members have voted' do
          allow(election).to receive(:users).and_return([bridge, at_large])

          expect(election).to be_compliant
        end
      end
    end
  end

  describe 'results' do
    it 'returns the correct single results' do
      election.style = 'single'
      election.immediate!
      ballot = FactoryBot.create(:ballot, election: election)
      FactoryBot.create(:vote, ballot: ballot, selection: 'Yes')

      expect(election.results).to eq('Yes' => 1)
    end

    it 'does not support preference results' do
      election.style = 'preference'

      expect { election.results }.to raise_error(RuntimeError, 'Not yet supported')
    end
  end
end
