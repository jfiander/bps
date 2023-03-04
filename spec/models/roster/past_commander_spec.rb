# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roster::PastCommander do
  let(:user) { create(:user, first_name: 'Jack', last_name: 'Frost') }

  describe 'validation' do
    context 'with a user' do
      it 'is valid without a name' do
        pc = build(:roster_past_commander, name: nil, user: user)
        expect(pc.valid?).to be(true)
      end

      it 'is valid with a name' do
        pc = build(:roster_past_commander, name: 'John Doe', user: user)
        expect(pc.valid?).to be(true)
      end
    end

    context 'without a user' do
      it 'is not valid without a name' do
        pc = build(:roster_past_commander, name: nil, user_id: nil)
        expect(pc.valid?).to be(false)
      end

      it 'is valid with a name' do
        pc = build(:roster_past_commander, name: 'John Doe', user_id: nil)
        expect(pc.valid?).to be(true)
      end
    end
  end

  describe 'display_name' do
    context 'with a user' do
      it "returns the user's name without a separate name" do
        pc = build(:roster_past_commander, name: nil, user: user)
        expect(pc.display_name).to eql('Jack Frost')
      end

      it "returns the user's name with a separate name" do
        pc = build(:roster_past_commander, name: 'John Doe', user: user)
        expect(pc.display_name).to eql('Jack Frost')
      end
    end

    it 'returns the name if no user is present' do
      pc = build(:roster_past_commander, name: 'John Doe', user_id: nil)
      expect(pc.display_name).to eql('John Doe')
    end
  end
end
