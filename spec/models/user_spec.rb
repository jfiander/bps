require 'rails_helper'

RSpec.describe User, type: :model do
  let(:blank_photo) { 'https://static.bpsd9.org/no_profile.png' }

  context 'new user' do
    before(:each) do
      @user = FactoryBot.build(:user)
    end

    it 'should default to the blank profile photo' do
      expect(@user.photo).to eql(blank_photo)
    end
  end

  describe 'validations' do
    it 'should reject invalid ranks' do
      user = FactoryBot.build(:user, rank: 'D/F/Lt/C')
      expect(user).not_to be_valid
    end

    it 'should accept valid ranks' do
      user = FactoryBot.build(:user, rank: 'D/F/Lt')
      expect(user).to be_valid
    end

    it 'should reject invalid grades' do
      user = FactoryBot.build(:user, grade: 'SP')
      expect(user).not_to be_valid
    end

    it 'should accept valid grades' do
      user = FactoryBot.build(:user, grade: 'JN')
      expect(user).to be_valid
    end

    it 'should replace blank ranks with nil' do
      user = FactoryBot.build(:user, rank: ' ')
      user.validate
      expect(user.rank).to be_nil
    end
  end

  describe 'miscellaneous' do
    before(:each) do
      @user = FactoryBot.create(
        :user,
        first_name: 'John',
        last_name: 'Doe',
        rank: 'Lt/C',
        grade: 'AP'
      )
    end

    it 'should have the correct simple_name' do
      expect(@user.simple_name).to eql('John Doe')
    end

    it 'should have the correct full_name' do
      expect(@user.full_name).to eql('Lt/C John Doe, AP')
    end

    it 'should return the correct bridge_hash' do
      expect(@user.bridge_hash).to eql(
        {
          full_name: 'Lt/C&nbsp;John&nbsp;Doe,&nbsp;AP',
          simple_name: 'John&nbsp;Doe',
          photo: blank_photo
        }
      )
    end

    it 'should correctly detect auto_ranks' do
      FactoryBot.create(
        :bridge_office,
        office: 'commander',
        user: @user
      )

      expect(@user.auto_rank).to eql('Cdr')
    end
  end

  describe 'invitable' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end
    #   !has_placeholder_email?

    it 'should not have accepted an invitation' do
      expect(@user.invitable?).to be(true)
      @user.update(invitation_accepted_at: Time.now)
      expect(@user.invitable?).to be(false)
    end

    it 'should not be logged in' do
      expect(@user.invitable?).to be(true)
      @user.update(current_sign_in_at: Time.now)
      expect(@user.invitable?).to be(false)
    end

    it 'should not be locked' do
      expect(@user.invitable?).to be(true)
      @user.lock
      expect(@user.invitable?).to be(false)
    end

    it 'should not have a sign in count' do
      expect(@user.invitable?).to be(true)
      @user.update(sign_in_count: 1)
      expect(@user.invitable?).to be(false)
    end

    it 'should not have a placeholder email' do
      expect(@user.invitable?).to be(true)
      @user.update(email: 'duplicate-12345@bpsd9.org')
      expect(@user.invitable?).to be(false)
      @user.update(email: 'nobody-12345@bpsd9.org')
      expect(@user.invitable?).to be(false)
    end
  end

  describe 'registration' do
    before(:each) do
      @user = FactoryBot.create(
        :user,
        first_name: 'John',
        last_name: 'Doe',
        rank: 'Lt/C',
        grade: 'AP'
      )

      @event = FactoryBot.create(:event)
    end

    it 'should create a valid registration' do
      reg = @user.register_for(@event)
      expect(reg).to be_valid
    end
  end

  describe 'permissions' do
    before(:all) do
      @admin = FactoryBot.build(:role, name: 'admin').save(validate: false)
      @child = FactoryBot.create(:role, name: 'child', parent: Role.find_by(name: 'admin'))
    end

    before(:each) do
      @user = FactoryBot.create(:user)
    end

    it 'should add permissions correctly' do
      user_role = @user.permit! :child
      expect(user_role.user).to eql(@user)
      expect(user_role.role.name).to eql('child')
    end

    it 'should return true when a user has the required permission' do
      @user.permit! :child
      @user.reload
      expect(@user.permitted?(:child)).to be(true)
    end

    it 'should return true when a user has a parent of the required permission' do
      @user.permit! :admin
      @user.reload
      expect(@user.permitted?(:child)).to be(true)
    end

    it 'should return false when a user does not have the required permission' do
      @user.reload
      expect(@user.permitted?(:child)).to be(false)
    end

    it "should return false when a role doesn't exist" do
      expect(@user.permitted?(:not_a_permission)).to be(false)
    end

    it 'should return false for invalid/empty permissions' do
      expect(@user.permitted?(nil)).to be(false)
      expect(@user.permitted?([])).to be(false)
      expect(@user.permitted?({})).to be(false)
      expect(@user.permitted?('')).to be(false)
      expect(@user.permitted?(' ')).to be(false)
      expect(@user.permitted?(nil, [], {}, '', ' ')).to be(false)
    end

    it 'should return the correct lists of permissions' do
      @user.permit! :admin
      expect(@user.granted_roles).to eql([:admin])
      expect(@user.permitted_roles).to eql([:admin, :child])
    end
  end

  describe 'locking' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end

    it 'should not create locked users' do
      expect(@user.locked?).to be(false)
    end

    it 'should correctly lock users' do
      @user.lock
      expect(@user.locked?).to be(true)
    end

    it 'should correctly unlock users' do
      @user.lock
      expect(@user.locked?).to be(true)
      @user.unlock
      expect(@user.locked?).to be(false)
    end
  end
end
