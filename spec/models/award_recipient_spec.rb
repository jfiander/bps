require 'rails_helper'

RSpec.describe AwardRecipient, type: :model do
  describe 'validation' do
    context 'with a user' do
      before(:each) do
        @user = FactoryBot.create(:user)
      end

      it 'should be valid without a name' do
        ar = FactoryBot.build(:award_recipient, name: nil, user: @user)
        expect(ar.valid?).to be(true)
      end

      it 'should be valid with a name' do
        ar = FactoryBot.build(:award_recipient, name: 'John Doe', user: @user)
        expect(ar.valid?).to be(true)
      end
    end

    context 'without a user' do
      it 'should not be valid without a name' do
        ar = FactoryBot.build(:award_recipient, name: nil, user_id: nil)
        expect(ar.valid?).to be(false)
      end

      it 'should be valid with a name' do
        ar = FactoryBot.build(:award_recipient, name: 'John Doe', user_id: nil)
        expect(ar.valid?).to be(true)
      end
    end
  end

  describe 'scopes' do
    before(:each) do
      @ar1 = FactoryBot.create(:award_recipient, name: 'John Doe', user_id: nil, year: '2015-01-01')
      @ar2 = FactoryBot.create(:award_recipient, name: 'John Doe', user_id: nil, year: '2014-01-01')
      @ar3 = FactoryBot.create(:award_recipient, name: 'John Doe', user_id: nil, year: '2013-01-01')
    end

    describe 'current' do
      it 'should return only the latest from each award' do
        expect(AwardRecipient.current.to_a).to eql([@ar1])
      end
    end

    describe 'past' do
      it 'should return all except the latest from each award' do
        expect(AwardRecipient.past.to_a).to eql([@ar2, @ar3])
      end
    end
  end

  describe 'display_name' do
    context 'with a user' do
      before(:each) do
        @user = FactoryBot.create(:user, first_name: 'Jack', last_name: 'Frost')
      end

      it "should return the user's name without a separate name" do
        ar = FactoryBot.create(:award_recipient, name: nil, user: @user)
        expect(ar.display_name).to eql('Jack Frost')
      end

      it "should return the user's name with a separate name" do
        ar = FactoryBot.create(:award_recipient, name: 'John Doe', user: @user)
        expect(ar.display_name).to eql('Jack Frost')
      end

      it 'should return the combined name if an additional_user is present' do
        additional = FactoryBot.create(:user, first_name: 'Jane', last_name: 'Doe')
        ar = FactoryBot.create(:award_recipient, name: nil, user: @user, additional_user: additional)
        expect(ar.display_name).to eql('Jack Frost and Jane Doe')
      end
    end

    it 'should return the name if no user is present' do
      ar = FactoryBot.create(:award_recipient, name: 'John Doe', user_id: nil)
      expect(ar.display_name).to eql('John Doe')
    end
  end

  it 'should format the display year correctly' do
    ar = FactoryBot.create(:award_recipient, name: 'John Doe', user_id: nil, year: '2015-01-01')
    expect(ar.display_year).to eql('2015')
  end
end
