# frozen_string_literal: true

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

  context 'with specified user' do
    before(:each) do
      @user = FactoryBot.create(
        :user,
        first_name: 'John',
        last_name: 'Doe',
        rank: 'Lt/C',
        grade: 'AP'
      )
    end

    describe 'auto_rank' do
      it 'should correctly detect Cdr' do
        assign_bridge_office('commander', @user)
        expect(@user.auto_rank).to eql('Cdr')
      end

      it 'should correctly detect Lt/C' do
        assign_bridge_office('executive', @user)
        expect(@user.auto_rank).to eql('Lt/C')
      end

      it 'should correctly detect 1st/Lt' do
        @user.rank = nil
        assign_bridge_office('asst_secretary', @user)
        expect(@user.auto_rank(html: false)).to eql('1st/Lt')
      end

      it 'should return the correct string for a formatted rank' do
        @user.rank = nil
        assign_bridge_office('asst_educational', @user)
        expect(@user.auto_rank).to eql('1<sup>st</sup>/Lt')
      end

      it 'should return the correct string for a simple rank' do
        expect(@user.auto_rank).to eql('Lt/C')
      end
    end

    describe 'formatting' do
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

      describe 'BOC' do
        it 'should return nil for no BOC level' do
          expect(FactoryBot.create(:user).boc).to be_nil
        end

        describe 'with BOC level' do
          before(:each) do
            @user = FactoryBot.create(:user)
            FactoryBot.create(:course_completion, user: @user, course_key: 'BOC_IN')
          end

          it 'should return the correct BOC level' do
            expect(@user.boc).to eql('IN')
          end

          describe 'with endorsements' do
            before(:each) do
              FactoryBot.create(:course_completion, user: @user, course_key: 'BOC_CAN')
            end

            it 'should return the correct BOC level with endorsements' do
              expect(@user.boc).to eql('IN (CAN)')
            end

            it 'should generate the correct grade suffix' do
              expect(@user.boc_display).to eql('-IN')
            end
          end
        end
      end

      it 'should return the correct bridge_hash' do
        expect(@user.bridge_hash).to eql(
          full_name: 'Lt/C&nbsp;John&nbsp;Doe,&nbsp;AP',
          simple_name: 'John&nbsp;Doe',
          photo: blank_photo
        )
      end
    end
  end

  describe 'inviting' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @placeholder_user = FactoryBot.create(:user, :placeholder_email)
    end

    it 'should be invitable by default' do
      expect(@user.invitable?).to be(true)
    end

    it 'should not have accepted an invitation' do
      @user.update(invitation_accepted_at: Time.now)
      expect(@user.invitable?).to be(false)
    end

    it 'should not be logged in' do
      @user.update(current_sign_in_at: Time.now)
      expect(@user.invitable?).to be(false)
    end

    it 'should not be locked' do
      @user.lock
      expect(@user.invitable?).to be(false)
    end

    it 'should not have a sign in count' do
      @user.update(sign_in_count: 1)
      expect(@user.invitable?).to be(false)
    end

    it 'should not have a placeholder email' do
      expect(@placeholder_user.invitable?).to be(false)
    end

    it 'should have received but not accepted an invitation' do
      @user.update(invitation_sent_at: Time.now)
      expect(@user.invited?).to be(true)
    end
  end

  describe 'registration' do
    it 'should create a valid registration' do
      @user = FactoryBot.create(
        :user,
        first_name: 'John',
        last_name: 'Doe',
        rank: 'Lt/C',
        grade: 'AP',
        email: "registrant-#{SecureRandom.hex(8)}@example.com"
      )
      @event = FactoryBot.create(:event)
      seo = FactoryBot.create(
        :user,
        first_name: 'Ed',
        last_name: 'Ucation',
        rank: 'Lt/C',
        grade: 'SN',
        email: "seo-#{SecureRandom.hex(8)}@example.com"
      )
      assign_bridge_office('educational', seo)

      reg = @user.register_for(@event)
      expect(reg).to be_valid
    end
  end

  describe 'permissions' do
    before(:all) do
      @admin = FactoryBot.build(:role, name: 'admin').save(validate: false)
      @child = FactoryBot.create(
        :role,
        name: 'child',
        parent: Role.find_by(name: 'admin')
      )
    end

    before(:each) do
      @user = FactoryBot.create(:user)
    end

    it 'should add permissions correctly' do
      user_role = @user.permit! :child
      expect(user_role.user).to eql(@user)
      expect(user_role.role.name).to eql('child')
    end

    describe 'removal' do
      before(:each) do
        @user.permit! :admin
        @user.permit! :child
      end

      it 'should remove permissions correctly' do
        @user.unpermit! :child
        expect(@user.permitted_roles).to include(:admin)
      end

      it 'should remove all permissions correctly' do
        @user.unpermit! :all
        expect(@user.permitted_roles).to be_blank
      end
    end

    it 'should return true when user has the required permission' do
      @user.permit! :child
      @user.reload
      expect(@user.permitted?(:child)).to be(true)
    end

    it 'should return true when user has a parent of the required permission' do
      @user.permit! :admin
      @user.reload
      expect(@user.permitted?(:child)).to be(true)
    end

    it 'should return false when user does not have the required permission' do
      @user.reload
      expect(@user.permitted?(:child)).to be(false)
    end

    it "should return false when a role doesn't exist" do
      expect(@user.permitted?(:not_a_permission)).to be(false)
    end

    it 'should return true when user has the required cached permission' do
      session = { permitted: [:child], granted: [:child] }
      expect(@user.permitted?(:child, session: session)).to be(true)
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
      expect(@user.permitted_roles).to eql(%i[admin child])
    end

    describe 'show_admin_menu?' do
      before(:each) do
        @page = FactoryBot.create(:role, name: 'page')
      end

      it 'should show the admin menu for correct users' do
        @user.permit! :page
        expect(@user.show_admin_menu?).to be(true)
      end

      it 'should not show the admin menu for other users' do
        expect(@user.show_admin_menu?).to be(false)
      end
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

  describe 'scopes' do
    it 'should get only invitable users' do
      user = FactoryBot.create(:user)
      FactoryBot.create(:user, :placeholder_email)
      FactoryBot.create(:user, sign_in_count: 1)

      expect(User.include_positions.invitable.to_a).to eql([user])
    end
  end

  describe 'address' do
    user = FactoryBot.create(
      :user,
      address_1: '123 ABC St',
      city: 'City',
      state: 'ST',
      zip: '12345'
    )

    it 'should return a correct address array' do
      expect(user.mailing_address).to eql(
        [
          user.full_name,
          user.address_1,
          "#{user.city} #{user.state} #{user.zip}"
        ]
      )
    end
  end

  describe 'profile photo' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @photo = File.new(test_image(500, 750))
      @key = 'profile_photos/0/original/blank.jpg'
    end

    it 'should return the default photo if not present' do
      expect(@user.photo).to eql(User.no_photo)
    end

    it 'should require a file path' do
      expect { @user.assign_photo }.to raise_error(
        ArgumentError, 'missing keyword: local_path'
      )

      expect { @user.assign_photo(local_path: @photo.path) }.not_to raise_error
    end

    it 'should have a photo after attaching' do
      @user.assign_photo(local_path: @photo.path)
      expect(@user.photo).to eql(
        User.buckets[:files].link(@user.profile_photo.s3_object(:medium).key)
      )
    end
  end

  describe 'dues' do
    before(:each) do
      @parent = FactoryBot.create(:user)
    end

    it 'should return the correct single member amount' do
      expect(@parent.dues).to eql(89)
    end

    it 'should return the correct discounted amount' do
      expect(@parent.discounted_amount).to eql(86.75)
    end

    context 'family' do
      before(:each) do
        @child = FactoryBot.create(:user, parent: @parent)
      end

      it 'should return the correct family amount' do
        expect(@parent.dues).to eql(134)
      end

      it 'should return the parent_id hash if a parent is assigned' do
        expect(@child.dues).to eql(user_id: @parent.id)
      end
    end
  end

  describe 'dues_due' do
    before(:each) do
      @parent = FactoryBot.create(:user)
      @child = FactoryBot.create(:user, parent: @parent)
    end

    it 'should return false with if not the head of a family' do
      expect(@child.dues_due?).to be(false)
    end

    it 'should return false with dues paid within 11 months' do
      @parent.update(dues_last_paid_at: 3.months.ago)
      expect(@parent.dues_due?).to be(false)
    end

    it 'should return true with dues paid over 11 months ago' do
      @parent.update(dues_last_paid_at: 11.months.ago)
      expect(@parent.dues_due?).to be(true)
    end
  end

  describe 'valid_instructor?' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end

    it 'should return false for a nil id_expr' do
      expect(@user.valid_instructor?).to be(false)
    end

    it 'should return false for a past id_expr' do
      @user.update(id_expr: Time.now - 1.month)
      expect(@user.valid_instructor?).to be(false)
    end

    it 'should return true for a future id_expr' do
      @user.update(id_expr: Time.now + 1.month)
      expect(@user.valid_instructor?).to be(true)
    end
  end

  describe 'vessel_examiner?' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end

    it 'should return false without VSC training' do
      expect(@user.vessel_examiner?).to be(false)
    end

    it 'should return true with VSC training' do
      FactoryBot.create(:course_completion, user: @user, course_key: 'VSC_01', date: Date.today)
      expect(@user.vessel_examiner?).to be(true)
    end
  end

  it 'should return the correct associations to include' do
    expect(User.position_associations).to eql(
      %i[bridge_office standing_committee_offices committees user_roles roles]
    )
  end
end
