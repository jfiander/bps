# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:blank_photo) { 'https://static.bpsd9.org/no_profile.png' }

  context 'with a new user' do
    before do
      @user = FactoryBot.build(:user)
    end

    it 'defaults to the blank profile photo' do
      expect(@user.photo).to eql(blank_photo)
    end
  end

  describe 'validations' do
    it 'rejects invalid ranks' do
      user = FactoryBot.build(:user, rank: 'D/F/Lt/C')
      expect(user).not_to be_valid
    end

    it 'accepts valid ranks' do
      user = FactoryBot.build(:user, rank: 'D/F/Lt')
      expect(user).to be_valid
    end

    it 'rejects invalid grades' do
      user = FactoryBot.build(:user, grade: 'SP')
      expect(user).not_to be_valid
    end

    it 'accepts valid grades' do
      user = FactoryBot.build(:user, grade: 'JN')
      expect(user).to be_valid
    end

    it 'replaces blank ranks with nil' do
      user = FactoryBot.build(:user, rank: ' ')
      user.validate
      expect(user.rank).to be_nil
    end
  end

  context 'with specified user' do
    before do
      @user = FactoryBot.create(:user, first_name: 'John', last_name: 'Doe', rank: 'Lt/C', grade: 'AP')
    end

    describe 'auto_rank' do
      it 'correctlies detect Cdr' do
        assign_bridge_office('commander', @user)
        expect(@user.auto_rank).to eql('Cdr')
      end

      it 'correctlies detect Lt/C' do
        assign_bridge_office('executive', @user)
        expect(@user.auto_rank).to eql('Lt/C')
      end

      it 'correctlies detect 1st/Lt' do
        @user.rank = nil
        assign_bridge_office('asst_secretary', @user)
        expect(@user.auto_rank(html: false)).to eql('1st/Lt')
      end

      it 'returns the correct string for a formatted rank' do
        @user.rank = nil
        assign_bridge_office('asst_educational', @user)
        expect(@user.auto_rank).to eql('1<sup>st</sup>/Lt')
      end

      it 'returns the correct string for a simple rank' do
        expect(@user.auto_rank).to eql('Lt/C')
      end
    end

    describe 'formatting' do
      before do
        @user = FactoryBot.create(:user, first_name: 'John', last_name: 'Doe', rank: 'Lt/C', grade: 'AP')
      end

      it 'has the correct simple_name' do
        expect(@user.simple_name).to eql('John Doe')
      end

      it 'has the correct full_name' do
        expect(@user.full_name).to eql('Lt/C John Doe, AP')
      end

      describe 'BOC' do
        it 'returns nil for no BOC level' do
          expect(FactoryBot.create(:user).boc).to be_nil
        end

        describe 'with BOC level' do
          before do
            @user = FactoryBot.create(:user)
            FactoryBot.create(:course_completion, user: @user, course_key: 'BOC_IN')
          end

          it 'returns the correct BOC level' do
            expect(@user.boc).to eql('IN')
          end

          describe 'with endorsements' do
            before do
              FactoryBot.create(:course_completion, user: @user, course_key: 'BOC_CAN')
            end

            it 'returns the correct BOC level with endorsements' do
              expect(@user.boc).to eql('IN (CAN)')
            end

            it 'generates the correct grade suffix' do
              expect(@user.boc_display).to eql('-IN')
            end
          end
        end
      end

      it 'returns the correct bridge_hash' do
        expect(@user.bridge_hash).to eql(
          full_name: 'Lt/C&nbsp;John&nbsp;Doe,&nbsp;AP',
          simple_name: 'John&nbsp;Doe',
          photo: blank_photo
        )
      end
    end
  end

  describe 'inviting' do
    before do
      @user = FactoryBot.create(:user)
      @placeholder_user = FactoryBot.create(:user, :placeholder_email)
    end

    it 'is invitable by default' do
      expect(@user.invitable?).to be(true)
    end

    it 'does not have accepted an invitation' do
      @user.update(invitation_accepted_at: Time.now)
      expect(@user.invitable?).to be(false)
    end

    it 'is not logged in' do
      @user.update(current_sign_in_at: Time.now)
      expect(@user.invitable?).to be(false)
    end

    it 'is not locked' do
      @user.lock
      expect(@user.invitable?).to be(false)
    end

    it 'does not have a sign in count' do
      @user.update(sign_in_count: 1)
      expect(@user.invitable?).to be(false)
    end

    it 'does not have a placeholder email' do
      expect(@placeholder_user.invitable?).to be(false)
    end

    it 'has received but not accepted an invitation' do
      @user.update(invitation_sent_at: Time.now)
      expect(@user.invited?).to be(true)
    end
  end

  describe 'registration' do
    it 'creates a valid registration' do
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
    before do
      @admin = FactoryBot.build(:role, name: 'admin').save(validate: false)
      @child = FactoryBot.create(:role, name: 'child', parent: Role.find_by(name: 'admin'))
      @user = FactoryBot.create(:user)
    end

    it 'adds permissions correctly' do
      user_role = @user.permit! :child
      expect(user_role.user).to eql(@user)
      expect(user_role.role.name).to eql('child')
    end

    describe 'removal' do
      before do
        @user.permit! :admin
        @user.permit! :child
      end

      it 'removes permissions correctly' do
        @user.unpermit! :child
        expect(@user.permitted_roles).to include(:admin)
      end

      it 'removes all permissions correctly' do
        @user.unpermit! :all
        expect(@user.permitted_roles).to be_blank
      end
    end

    it 'returns true when user has the required permission' do
      @user.permit! :child
      @user.reload
      expect(@user.permitted?(:child)).to be(true)
    end

    it 'returns true when user has a parent of the required permission' do
      @user.permit! :admin
      @user.reload
      expect(@user.permitted?(:child)).to be(true)
    end

    it 'returns false when user does not have the required permission' do
      @user.reload
      expect(@user.permitted?(:child)).to be(false)
    end

    it "returns false when a role doesn't exist" do
      expect(@user.permitted?(:not_a_permission)).to be(false)
    end

    it 'returns true when user has the required cached permission' do
      session = { permitted: [:child], granted: [:child] }
      expect(@user.permitted?(:child, session: session)).to be(true)
    end

    it 'returns false for invalid/empty permissions' do
      expect(@user.permitted?(nil)).to be(false)
      expect(@user.permitted?([])).to be(false)
      expect(@user.permitted?({})).to be(false)
      expect(@user.permitted?('')).to be(false)
      expect(@user.permitted?(' ')).to be(false)
      expect(@user.permitted?(nil, [], {}, '', ' ')).to be(false)
    end

    it 'returns the correct lists of permissions' do
      @user.permit! :admin
      expect(@user.granted_roles).to eql([:admin])
      expect(@user.permitted_roles).to eql(%i[admin child])
    end

    describe 'show_admin_menu?' do
      before do
        @page = FactoryBot.create(:role, name: 'page')
      end

      it 'shows the admin menu for correct users' do
        @user.permit! :page
        expect(@user.show_admin_menu?).to be(true)
      end

      it 'does not show the admin menu for other users' do
        expect(@user.show_admin_menu?).to be(false)
      end
    end
  end

  describe 'locking' do
    before do
      @user = FactoryBot.create(:user)
    end

    it 'does not create locked users' do
      expect(@user.locked?).to be(false)
    end

    it 'correctlies lock users' do
      @user.lock
      expect(@user.locked?).to be(true)
    end

    it 'correctlies unlock users' do
      @user.lock
      expect(@user.locked?).to be(true)
      @user.unlock
      expect(@user.locked?).to be(false)
    end
  end

  describe 'scopes' do
    before do
      @user_inv = FactoryBot.create(:user)
      @user_pe = FactoryBot.create(:user, email: 'nobody-asdfhjkl@bpsd9.org')
      @user_inst = FactoryBot.create(:user, sign_in_count: 1, id_expr: Time.now + 1.year)
      @user_vse = FactoryBot.create(:user, sign_in_count: 23)
      @user_vse.course_completions << FactoryBot.create(
        :course_completion, user: @user_vse, course_key: 'VSC_01', date: Time.now - 1.month
      )
    end

    it 'returns the list of invitable users' do
      expect(User.invitable.to_a).to eql([@user_inv])
    end

    it 'returns the list of valid instructor users' do
      expect(User.valid_instructors.to_a).to eql([@user_inst])
    end

    it 'returns the list of vessel examiner users' do
      expect(User.vessel_examiners.to_a).to eql([@user_vse])
    end
  end

  describe 'address' do
    user = FactoryBot.create(:user, address_1: '100 N Capitol Ave', city: 'Lansing', state: 'MI', zip: '48933')

    it 'returns a correct address array' do
      expect(user.mailing_address).to eql([user.full_name, user.address_1, "#{user.city} #{user.state} #{user.zip}"])
    end

    it 'returns valid Lat Lon' do
      expect(user.lat_lon(human: false).join("\t")).to match(/-?\d{1,3}\.\d+\t-?\d{1,3}\.\d+/)
    end

    it 'returns valid human-readable Lat Lon' do
      expect(user.lat_lon(human: true)).to match(/\d{1,3}° \d{1,2}\.\d{1,5}′ [NS]\t\d{1,3}° \d{1,2}\.\d{1,5}′ [EW]/)
    end
  end

  describe 'profile photo' do
    before do
      @user = FactoryBot.create(:user)
      @photo = File.new(test_image(500, 750))
      @key = 'profile_photos/0/original/blank.jpg'
    end

    it 'returns the default photo if not present' do
      expect(@user.photo).to eql(User.no_photo)
    end

    it 'requires a file path' do
      expect { @user.assign_photo }.to raise_error(ArgumentError, 'missing keyword: local_path')

      expect { @user.assign_photo(local_path: @photo.path) }.not_to raise_error
    end

    it 'has a photo after attaching' do
      @user.assign_photo(local_path: @photo.path)
      expect(@user.photo).to eql(User.buckets[:files].link(@user.profile_photo.s3_object(:medium).key))
    end
  end

  describe 'dues' do
    before do
      @parent = FactoryBot.create(:user)
    end

    it 'returns the correct single member amount' do
      expect(@parent.dues).to be(89)
    end

    it 'returns the correct discounted amount' do
      expect(@parent.discounted_amount).to eq(86.75)
    end

    context 'with family' do
      before do
        @child = FactoryBot.create(:user, parent: @parent)
      end

      it 'returns the correct family amount' do
        expect(@parent.dues).to eq(134)
      end

      it 'returns the parent_id hash if a parent is assigned' do
        expect(@child.dues).to eql(user_id: @parent.id)
      end

      describe 'payable?' do
        it 'returns true for a parent' do
          expect(@parent.payable?).to be(true)
        end

        it 'returns false for a child' do
          expect(@child.payable?).to be(false)
        end

        it 'returns true for a recently-paid member' do
          @parent.dues_paid!
          expect(@parent.payable?).to be(true)
        end
      end
    end
  end

  describe 'dues_due' do
    before do
      @parent = FactoryBot.create(:user)
      @child = FactoryBot.create(:user, parent: @parent)
    end

    it 'returns false with if not the head of a family' do
      expect(@child.dues_due?).to be(false)
    end

    it 'returns false with dues paid within 11 months' do
      @parent.update(dues_last_paid_at: 3.months.ago)
      expect(@parent.dues_due?).to be(false)
    end

    it 'returns true with dues paid over 11 months ago' do
      @parent.update(dues_last_paid_at: 11.months.ago)
      expect(@parent.dues_due?).to be(true)
    end
  end

  describe 'valid_instructor?' do
    before do
      @user = FactoryBot.create(:user)
    end

    it 'returns false for a nil id_expr' do
      expect(@user.valid_instructor?).to be(false)
    end

    it 'returns false for a past id_expr' do
      @user.update(id_expr: Time.now - 1.month)
      expect(@user.valid_instructor?).to be(false)
    end

    it 'returns true for a future id_expr' do
      @user.update(id_expr: Time.now + 1.month)
      expect(@user.valid_instructor?).to be(true)
    end
  end

  describe 'vessel_examiner?' do
    before do
      @user = FactoryBot.create(:user)
    end

    it 'returns false without VSC training' do
      expect(@user.vessel_examiner?).to be(false)
    end

    it 'returns true with VSC training' do
      FactoryBot.create(:course_completion, user: @user, course_key: 'VSC_01', date: Date.today)
      expect(@user.vessel_examiner?).to be(true)
    end
  end

  describe 'cpr_aed?' do
    before do
      @user = FactoryBot.create(:user)
    end

    it 'returns false without the flag set' do
      expect(@user.cpr_aed?).to be(false)
    end

    it 'returns false with a past expiration date' do
      @user.update(cpr_aed_expires_at: Time.now - 1.day)
      expect(@user.cpr_aed?).to be(false)
    end

    it 'returns true with a future expiration date' do
      @user.update(cpr_aed_expires_at: Time.now + 1.day)
      expect(@user.cpr_aed?).to be(true)
    end
  end

  it 'returns the correct associations to include' do
    expect(User.position_associations).to eql(%i[bridge_office standing_committee_offices committees user_roles roles])
  end
end
