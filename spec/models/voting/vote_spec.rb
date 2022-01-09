# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Voting::Vote, type: :model do
  subject(:vote) { FactoryBot.build(:vote, ballot: ballot) }

  let(:ballot) { FactoryBot.create(:ballot, election: election) }
  let(:election) { FactoryBot.create(:election) }

  before { allow(election).to receive(:open?).and_return(true) }

  describe 'validations' do
    context 'with a preference election' do
      before { allow(election).to receive(:style).and_return('preference') }

      it 'rejects invalid preference', :aggregate_failures do
        vote.preference = 0

        expect(vote).not_to be_valid
        expect(vote.errors.messages).to include(preference: ['must be greater than 0'])
      end

      it 'rejects duplicate preference', :aggregate_failures do
        FactoryBot.create(:vote, ballot: ballot, preference: 1)
        vote.preference = 1

        expect(vote).not_to be_valid
        expect(vote.errors.messages).to include(preference: ['must be unique'])
      end

      it 'rejects duplicate selections', :aggregate_failures do
        FactoryBot.create(:vote, ballot: ballot, selection: 'A', preference: 1)
        vote.preference = 2
        vote.selection = 'A'

        expect(vote).not_to be_valid
        expect(vote.errors.messages).to include(selection: ['must be unique'])
      end
    end

    context 'with a single election' do
      before { allow(election).to receive(:style).and_return('single') }

      it 'rejects non-nil preference for single elections', :aggregate_failures do
        vote.preference = 1

        expect(vote).not_to be_valid
        expect(vote.errors.messages).to include(preference: ['must not be set'])
      end

      it 'rejects multiple selections', :aggregate_failures do
        FactoryBot.create(:vote, ballot: ballot, selection: 'A')

        expect(vote).not_to be_valid
        expect(vote.errors.messages).to include(base: ['Can only have one selection'])
      end
    end
  end

  describe 'validation switching' do
    before do
      allow(vote).to receive(:enforce_valid_preference)
      allow(vote).to receive(:enforce_nil_preference)
      allow(vote).to receive(:enforce_valid_selections)
      allow(vote).to receive(:enforce_single_vote)
    end

    describe '#validate_preference' do
      it 'enforces preference voting rules' do
        election.style = 'preference'

        expect(vote).to receive(:enforce_valid_preference)

        vote.save
      end

      it 'enforces single voting rules' do
        expect(vote).to receive(:enforce_nil_preference)

        vote.save
      end

      it 'rejects unrecognized styles' do
        allow(election).to receive(:style).and_return('not a thing')

        expect { vote.save }.to raise_error('Unrecognized election style: not a thing')
      end
    end

    describe '#validate_selection' do
      it 'enforces preference selection rules' do
        election.style = 'preference'

        expect(vote).to receive(:enforce_valid_selections)

        vote.save
      end

      it 'enforces single selection rules' do
        expect(vote).to receive(:enforce_single_vote)

        vote.save
      end
    end
  end
end
