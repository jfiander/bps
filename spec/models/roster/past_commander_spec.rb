require 'rails_helper'

RSpec.describe Roster::PastCommander, type: :model do
  describe 'validation' do
    context 'with a user' do
      before(:each) do
        @user = FactoryBot.create(:user)
      end

      it 'should be valid without a name' do
        pc = FactoryBot.build(:roster_past_commander, name: nil, user: @user)
        expect(pc.valid?).to be(true)
      end

      it 'should be valid with a name' do
        pc = FactoryBot.build(:roster_past_commander, name: 'John Doe', user: @user)
        expect(pc.valid?).to be(true)
      end
    end

    context 'without a user' do
      it 'should not be valid without a name' do
        pc = FactoryBot.build(:roster_past_commander, name: nil, user_id: nil)
        expect(pc.valid?).to be(false)
      end

      it 'should be valid with a name' do
        pc = FactoryBot.build(:roster_past_commander, name: 'John Doe', user_id: nil)
        expect(pc.valid?).to be(true)
      end
    end
  end

  describe 'display_name' do
    context 'with a user' do
      before(:each) do
        @user = FactoryBot.create(:user, first_name: 'Jack', last_name: 'Frost')
      end

      it "should return the user's name without a separate name" do
        pc = FactoryBot.build(:roster_past_commander, name: nil, user: @user)
        expect(pc.display_name).to eql('Jack Frost')
      end

      it "should return the user's name with a separate name" do
        pc = FactoryBot.build(:roster_past_commander, name: 'John Doe', user: @user)
        expect(pc.display_name).to eql('Jack Frost')
      end
    end

    it 'should return the name if no user is present' do
      pc = FactoryBot.build(:roster_past_commander, name: 'John Doe', user_id: nil)
      expect(pc.display_name).to eql('John Doe')
    end
  end
end
