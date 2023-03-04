# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roster::AwardRecipient do
  let(:user) { create(:user, first_name: 'Jack', last_name: 'Frost') }

  describe 'validation' do
    context 'with a user' do
      it 'is valid without a name' do
        ar = build(:roster_award_recipient, name: nil, user: user)
        expect(ar.valid?).to be(true)
      end

      it 'is valid with a name' do
        ar = build(:roster_award_recipient, name: 'John Doe', user: user)
        expect(ar.valid?).to be(true)
      end
    end

    context 'without a user' do
      it 'is not valid without a name' do
        ar = build(:roster_award_recipient, name: nil, user_id: nil)
        expect(ar.valid?).to be(false)
      end

      it 'is valid with a name' do
        ar = build(:roster_award_recipient, name: 'John Doe', user_id: nil)
        expect(ar.valid?).to be(true)
      end
    end
  end

  describe 'scopes' do
    let!(:ar1) { create(:roster_award_recipient, name: 'John Doe', user_id: nil, year: '2015-01-01') }
    let!(:ar2) { create(:roster_award_recipient, name: 'John Doe', user_id: nil, year: '2014-01-01') }
    let!(:ar3) { create(:roster_award_recipient, name: 'John Doe', user_id: nil, year: '2013-01-01') }

    describe 'current' do
      it 'returns only the latest from each award' do
        expect(described_class.current.to_a).to eql([ar1])
      end
    end

    describe 'past' do
      it 'returns all except the latest from each award in chronological order' do
        expect(described_class.past.to_a).to eql([ar3, ar2])
      end
    end
  end

  describe 'display_name' do
    context 'with a user' do
      it "returns the user's name without a separate name" do
        ar = create(:roster_award_recipient, name: nil, user: user)
        expect(ar.display_name).to eql('Jack Frost')
      end

      it "returns the user's name with a separate name" do
        ar = create(:roster_award_recipient, name: 'John Doe', user: user)
        expect(ar.display_name).to eql('Jack Frost')
      end

      it 'returns the combined name if an additional_user is present' do
        additional = create(:user, first_name: 'Jane', last_name: 'Doe')
        ar = create(:roster_award_recipient, name: nil, user: user, additional_user: additional)
        expect(ar.display_name).to eql('Jack Frost and Jane Doe')
      end
    end

    it 'returns the name if no user is present' do
      ar = create(:roster_award_recipient, name: 'John Doe', user_id: nil)
      expect(ar.display_name).to eql('John Doe')
    end
  end

  it 'formats the display year correctly' do
    ar = create(:roster_award_recipient, name: 'John Doe', user_id: nil, year: '2015-01-01')
    expect(ar.display_year).to eql('2015')
  end
end
