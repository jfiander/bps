# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:blank_photo) { 'https://static.bpsd9.org/no_profile.png' }
  let(:user) { create(:user) }

  context 'with a new user' do
    let(:user) { build(:user) }

    it 'defaults to the blank profile photo' do
      expect(user.photo).to eql(blank_photo)
    end
  end

  describe 'validations' do
    it 'rejects invalid ranks' do
      user = build(:user, rank: 'D/F/Lt/C')
      expect(user).not_to be_valid
    end

    it 'accepts valid ranks' do
      user = build(:user, rank: 'D/F/Lt')
      expect(user).to be_valid
    end

    it 'rejects invalid grades' do
      user = build(:user, grade: 'SP')
      expect(user).not_to be_valid
    end

    it 'accepts valid grades' do
      user = build(:user, grade: 'JN')
      expect(user).to be_valid
    end

    it 'replaces blank ranks with nil' do
      user = build(:user, rank: ' ')
      user.validate
      expect(user.rank).to be_nil
    end

    it 'rejects invalid phone_c' do
      user = build(:user, phone_c: 'not-a-number')
      user.validate
      expect(user).not_to be_valid
    end
  end

  context 'with specified user' do
    let(:user) { create(:user, first_name: 'John', last_name: 'Doe', rank: 'Lt/C', grade: 'AP') }

    describe 'auto_rank' do
      it 'correctlies detect Cdr' do
        assign_bridge_office('commander', user)
        expect(user.auto_rank).to eql('Cdr')
      end

      it 'correctlies detect Lt/C' do
        assign_bridge_office('executive', user)
        expect(user.auto_rank).to eql('Lt/C')
      end

      it 'correctlies detect 1st/Lt' do
        user.rank = nil
        assign_bridge_office('asst_secretary', user)
        expect(user.auto_rank(html: false)).to eql('1st/Lt')
      end

      it 'returns the correct string for a formatted rank' do
        user.rank = nil
        assign_bridge_office('asst_educational', user)
        expect(user.auto_rank).to eql('1<sup>st</sup>/Lt')
      end

      it 'returns the correct string for a simple rank' do
        expect(user.auto_rank).to eql('Lt/C')
      end
    end

    describe '#stripe_rank' do
      it 'returns the correct rank, properly formatted' do
        allow(user).to receive(:ranks).and_return(['R/C', 'Lt/C', 'D/Lt'])

        expect(user.stripe_rank).to eq('rc')
      end

      it 'includes GB Emeritus' do
        allow(user).to receive_messages(ranks: ['Lt/C', 'D/Lt'], mm: 50)

        expect(user.stripe_rank).to eq('stfc')
      end

      it 'allows a manual override' do
        allow(user).to receive_messages(
          ranks: ['Stf/C', 'Lt/C', 'D/Lt'],
          preferred_stripe_rank: 'P/R/C'
        )

        expect(user.stripe_rank).to eq('prc')
      end

      describe 'regexes' do
        let(:narrow) { User::Stripes::NARROW }
        let(:two)    { User::Stripes::TWO }
        let(:three)  { User::Stripes::THREE }
        let(:four)   { User::Stripes::FOUR }
        let(:levels) { %i[NATIONAL DISTRICT SQUADRON].map { |l| User::Stripes.const_get(l) } }

        shared_examples 'has four stripes with' do |level|
          it('has the correct main stripe') { expect(rank).to match(level) }
          it('has a second stripe')         { expect(rank).to match(two) }
          it('has a third stripe')          { expect(rank).to match(three) }
          it('has a fourth stripe')         { expect(rank).to match(four) }

          it 'does not have the incorrect stripes', :aggregate_failures do
            (levels - [level]).each { |l| expect(rank).not_to match(l) }
          end
        end

        shared_examples 'has three stripes with' do |level|
          it('has the correct main stripe')   { expect(rank).to match(level) }
          it('has a second stripe')           { expect(rank).to match(two) }
          it('has a third stripe')            { expect(rank).to match(three) }
          it('does not have a fourth stripe') { expect(rank).not_to match(four) }

          it 'does not have the incorrect stripes', :aggregate_failures do
            (levels - [level]).each { |l| expect(rank).not_to match(l) }
          end
        end

        shared_examples 'has two stripes with' do |level|
          it('has the correct main stripe')   { expect(rank).to match(level) }
          it('has a second stripe')           { expect(rank).to match(two) }
          it('does not have a third stripe')  { expect(rank).not_to match(three) }
          it('does not have a fourth stripe') { expect(rank).not_to match(four) }

          it 'does not have the incorrect stripes', :aggregate_failures do
            (levels - [level]).each { |l| expect(rank).not_to match(l) }
          end
        end

        shared_examples 'has one stripe with' do |level|
          it('has the correct main stripe')   { expect(rank).to match(level) }
          it('does not have a second stripe') { expect(rank).not_to match(two) }
          it('does not have a third stripe')  { expect(rank).not_to match(three) }
          it('does not have a fourth stripe') { expect(rank).not_to match(four) }

          it 'does not have the incorrect stripes', :aggregate_failures do
            (levels - [level]).each { |l| expect(rank).not_to match(l) }
          end
        end

        describe 'no rank' do
          let(:rank) { nil }

          it('does not have a second stripe') { expect(rank).not_to match(two) }
          it('does not have a third stripe')  { expect(rank).not_to match(three) }
          it('does not have a fourth stripe') { expect(rank).not_to match(four) }

          it 'does not have a main stripe', :aggregate_failures do
            levels.each { |l| expect(rank).not_to match(l) }
          end
        end

        describe 'national' do
          context 'with cc' do
            %w[cc pcc].each do |r|
              let(:rank) { r }

              include_examples 'has four stripes with', User::Stripes::NATIONAL
              it('is narrow-spaced') { expect(rank).to match(narrow) }
            end
          end

          context 'with vc' do
            %w[vc pvc].each do |r|
              let(:rank) { r }

              include_examples 'has three stripes with', User::Stripes::NATIONAL
            end
          end

          context 'with rc' do
            %w[rc prc].each do |r|
              let(:rank) { r }

              include_examples 'has two stripes with', User::Stripes::NATIONAL
            end
          end

          context 'with other national' do
            %w[stfc pstfc nflt pnflt naide].each do |r|
              let(:rank) { r }

              include_examples 'has one stripe with', User::Stripes::NATIONAL
            end
          end
        end

        describe 'district' do
          context 'with dc' do
            %w[dc pdc].each do |r|
              let(:rank) { r }

              include_examples 'has four stripes with', User::Stripes::DISTRICT
              it('is narrow-spaced') { expect(rank).to match(narrow) }
            end
          end

          context 'with dltc' do
            %w[dltc pdltc].each do |r|
              let(:rank) { r }

              include_examples 'has three stripes with', User::Stripes::DISTRICT
            end
          end

          context 'with d1lt' do
            %w[dfirstlt].each do |r|
              let(:rank) { r }

              include_examples 'has two stripes with', User::Stripes::DISTRICT
            end
          end

          context 'with other district' do
            %w[dlt dflt daide].each do |r|
              let(:rank) { r }

              include_examples 'has one stripe with', User::Stripes::DISTRICT
            end
          end
        end

        describe 'squadron' do
          context 'with cdr' do
            %w[cdr pc].each do |r|
              let(:rank) { r }

              include_examples 'has four stripes with', User::Stripes::SQUADRON
              it('is not narrow-spaced') { expect(rank).not_to match(narrow) }
            end
          end

          context 'with ltc' do
            %w[ltc pltc].each do |r|
              let(:rank) { r }

              include_examples 'has three stripes with', User::Stripes::SQUADRON
            end
          end

          context 'with 1lt' do
            %w[firstlt].each do |r|
              let(:rank) { r }

              include_examples 'has two stripes with', User::Stripes::SQUADRON
            end
          end

          context 'with other squadron' do
            %w[lt flt].each do |r|
              let(:rank) { r }

              include_examples 'has one stripe with', User::Stripes::SQUADRON
            end
          end
        end
      end
    end

    describe '#flag_rank' do
      it 'returns the correct rank' do
        allow(user).to receive(:ranks).and_return(['R/C', 'Lt/C', 'D/Lt'])

        expect(user.flag_rank).to eq('R/C')
      end

      it 'allows a manual override' do
        allow(user).to receive_messages(
          ranks: ['R/C', 'Lt/C', 'D/Lt'],
          preferred_flag_rank: 'P/N/F/Lt'
        )

        expect(user.flag_rank).to eq('P/N/F/Lt')
      end
    end

    describe '#first_stripe_class' do
      subject(:first_stripe_class) { user.first_stripe_class }

      it 'matches national' do
        allow(user).to receive(:stripe_rank).and_return('rc')

        expect(first_stripe_class).to eq(:national)
      end

      it 'matches district' do
        allow(user).to receive(:stripe_rank).and_return('dltc')

        expect(first_stripe_class).to eq(:district)
      end

      it 'matches squadron' do
        allow(user).to receive(:stripe_rank).and_return('flt')

        expect(first_stripe_class).to eq(:squadron)
      end

      it 'detects nothing' do
        allow(user).to receive(:stripe_rank).and_return(nil)

        expect(first_stripe_class).to eq(:hide)
      end
    end

    describe 'formatting' do
      it 'has the correct simple_name' do
        expect(user.simple_name).to eql('John Doe')
      end

      it 'has the correct full_name' do
        expect(user.full_name).to eql('Lt/C John Doe, AP')
      end

      describe 'BOC' do
        it 'returns nil for no BOC level' do
          expect(create(:user).boc).to be_nil
        end

        describe 'with BOC level' do
          let(:user) { create(:user) }
          let!(:completion) { create(:course_completion, user: user, course_key: 'BOC_IN') }

          it 'returns the correct BOC level' do
            expect(user.boc).to eql('IN')
          end

          describe 'with endorsements' do
            before do
              create(:course_completion, user: user, course_key: 'BOC_CAN')
            end

            it 'returns the correct BOC level with endorsements' do
              expect(user.boc).to eql('IN (CAN)')
            end

            it 'generates the correct grade suffix' do
              expect(user.boc_display).to eql('-IN')
            end
          end
        end
      end

      it 'returns the correct bridge_hash' do
        expect(user.bridge_hash).to eql(
          full_name: 'Lt/C&nbsp;John&nbsp;Doe,&nbsp;AP',
          simple_name: 'John&nbsp;Doe',
          photo: blank_photo
        )
      end
    end
  end

  describe 'inviting' do
    let(:user) { create(:user) }
    let(:placeholder_user) { create(:user, :placeholder_email) }

    it 'is invitable by default' do
      expect(user.invitable?).to be(true)
    end

    it 'does not have accepted an invitation' do
      user.update(invitation_accepted_at: Time.zone.now)
      expect(user.invitable?).to be(false)
    end

    it 'is not logged in' do
      user.update(current_sign_in_at: Time.zone.now)
      expect(user.invitable?).to be(false)
    end

    it 'is not locked' do
      user.lock
      expect(user.invitable?).to be(false)
    end

    it 'does not have a sign in count' do
      user.update(sign_in_count: 1)
      expect(user.invitable?).to be(false)
    end

    it 'does not have a placeholder email' do
      expect(placeholder_user.invitable?).to be(false)
    end

    it 'has received but not accepted an invitation' do
      user.update(invitation_sent_at: Time.zone.now)
      expect(user.invited?).to be(true)
    end

    describe '.invitable_from' do
      subject { described_class.invitable_from(user.id, already_invited.id) }

      let(:already_invited) { create(:user, invitation_sent_at: Time.zone.now) }

      it { is_expected.to eq([user]) }
    end
  end

  describe 'registration' do
    let(:event) { create(:event) }
    let(:user) { create(:user) }

    before { assign_bridge_office('educational', user) }

    it 'creates a valid registration' do
      reg = user.register_for(event)
      expect(reg).to be_valid
    end

    it 'finds an existing registration' do
      existing = user.register_for(event)

      reg = user.register_for(event)
      expect(reg).to eq(existing)
    end

    it 'creates a valid registration with an existing refunded registration' do
      original = user.register_for(event)
      original.payment.update(refunded: true)

      reg = user.register_for(event)
      expect(reg).to be_valid
    end
  end

  describe 'permissions' do
    let!(:admin) { create(:role, name: 'admin') }
    let!(:child) { create(:role, name: 'child', parent: admin) }
    let(:user) { create(:user) }

    it 'adds permissions correctly' do
      user_role = user.permit! :child
      expect(user_role.user).to eq(user)
      expect(user_role.role).to eq(child)
    end

    describe 'removal' do
      before do
        user.permit! :admin
        user.permit! :child
      end

      it 'removes permissions correctly' do
        user.unpermit! :child
        expect(user.permitted_roles).to include(:admin)
      end

      it 'removes all permissions correctly' do
        user.unpermit! :all
        expect(user.permitted_roles).to be_blank
      end
    end

    it 'returns true when user has the required permission' do
      user.permit! :child
      expect(user.reload).to be_permitted(:child)
    end

    it 'returns true when user has a parent of the required permission' do
      user.permit! :admin
      expect(user.reload).to be_permitted(:child)
    end

    it 'returns false when user does not have the required permission' do
      expect(user.reload).not_to be_permitted(:child)
    end

    it "returns false when a role doesn't exist" do
      expect(user).not_to be_permitted(:not_a_permission)
    end

    it 'returns false for invalid/empty permissions', :aggregate_failures do
      expect(user).not_to be_permitted(nil)
      expect(user).not_to be_permitted([])
      expect(user).not_to be_permitted({})
      expect(user).not_to be_permitted('')
      expect(user).not_to be_permitted(' ')
      expect(user).not_to be_permitted(nil, [], {}, '', ' ')
    end

    it 'returns the correct lists of permissions' do
      user.permit! :admin
      expect(user.granted_roles).to eq([:admin])
      expect(user.permitted_roles).to eq(%i[admin child])
      expect(user.implied_roles).to eq(%i[child])
    end

    describe 'show_admin_menu?' do
      let!(:page) { create(:role, name: 'page') }

      it 'shows the admin menu for correct users' do
        user.permit! :page
        expect(user).to be_show_admin_menu
      end

      it 'does not show the admin menu for other users' do
        expect(user).not_to be_show_admin_menu
      end
    end

    describe 'authorized_for_activity_feed?' do
      let!(:education) { create(:role, name: 'education') }
      let!(:event) { create(:role, name: 'event') }

      it 'does not allow a regular user to edit' do
        expect(user).not_to be_authorized_for_activity_feed
      end

      it 'allows an admin to edit' do
        user.permit! :admin
        expect(user).to be_authorized_for_activity_feed
      end

      context 'with education permissions' do
        it 'allows granted education permissions to edit' do
          user.permit! :education
          expect(user).to be_authorized_for_activity_feed
        end

        it 'allows implied education permissions to edit' do
          create(:bridge_office, office: 'asst_educational', user: user)
          expect(user).to be_authorized_for_activity_feed
        end
      end
    end

    describe 'role checkers' do
      let!(:education) { create(:role, name: 'education') }

      describe '#role?' do
        it 'is true when directly granted' do
          user.permit! :education
          expect(user).to be_role(:education)
        end

        it 'is true when implied' do
          user.permit! :admin
          expect(user).to be_role(:education)
        end

        it 'is false when not permitted' do
          expect(user).not_to be_role(:education)
        end
      end

      describe '#exact_role?' do
        it 'is true when directly granted' do
          user.permit! :education
          expect(user).to be_exact_role(:education)
        end

        it 'is false when implied' do
          user.permit! :admin
          expect(user).not_to be_exact_role(:education)
        end
      end
    end
  end

  describe 'locking' do
    let(:user) { create(:user) }

    it 'does not create locked users' do
      expect(user.locked?).to be(false)
    end

    it 'correctly lock users' do
      expect { user.lock }.to change { user.locked? }.to(true)
    end

    it 'correctly unlock users' do
      user.lock
      expect { user.unlock }.to change { user.locked? }.to(false)
    end
  end

  describe 'scopes' do
    let!(:user_inv) { create(:user) }
    let!(:user_pe) { create(:user, email: 'nobody-asdfhjkl@bpsd9.org') }
    let!(:user_inst) { create(:user, sign_in_count: 1, id_expr: 1.year.from_now) }
    let!(:user_vse) { create(:user, sign_in_count: 23) }

    before do
      user_vse.course_completions << create(
        :course_completion, user: user_vse, course_key: 'VSC_01', date: 1.month.ago
      )
    end

    it 'returns the list of invitable users' do
      expect(described_class.invitable.to_a).to eql([user_inv])
    end

    it 'returns the list of valid instructor users' do
      expect(described_class.valid_instructors.to_a).to eql([user_inst])
    end

    it 'returns the list of vessel examiner users' do
      expect(described_class.vessel_examiners.to_a).to eql([user_vse])
    end
  end

  describe 'address' do
    let(:user) { create(:user, address_1: '100 N Capitol Ave', city: 'Lansing', state: 'MI', zip: '48933') }

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
    let(:user) { create(:user) }
    let(:photo) { File.new(test_image(500, 750)) }

    it 'returns the default photo if not present' do
      expect(user.photo).to eql(described_class.no_photo)
    end

    it 'requires a file path' do
      expect { user.assign_photo }.to raise_error(ArgumentError, 'missing keyword: :local_path')

      expect { user.assign_photo(local_path: photo.path) }.not_to raise_error
    end

    it 'has a photo after attaching' do
      user.assign_photo(local_path: photo.path)

      expect(user.photo).to match(
        %r{https://files\.development\.bpsd9\.org/profile_photos/#{user.id}/medium/test_image\.jpg\?}
      )
    end
  end

  describe 'dues' do
    it 'returns the correct single member amount' do
      expect(user.dues).to be(93)
    end

    it 'returns the correct discounted amount' do
      expect(user.discounted_amount).to eq(90.66)
    end

    context 'with family' do
      let!(:child) { create(:user, parent: user) }

      it 'returns the correct family amount' do
        expect(user.dues).to eq(140)
      end

      it 'returns the parent_id hash if a parent is assigned' do
        expect(child.dues).to eql(user_id: user.id)
      end

      describe 'payable?' do
        it 'returns true for a parent' do
          expect(user.payable?).to be(true)
        end

        it 'returns false for a child' do
          expect(child.payable?).to be(false)
        end

        it 'returns true for a recently-paid member' do
          user.dues_paid!
          expect(user.payable?).to be(true)
        end
      end
    end
  end

  describe 'dues_due' do
    let(:child) { create(:user, parent: user) }

    it 'returns false with if not the head of a family' do
      expect(child.dues_due?).to be(false)
    end

    it 'returns false with dues paid within 11 months' do
      user.update(dues_last_paid_at: 3.months.ago)
      expect(user.dues_due?).to be(false)
    end

    it 'returns true with dues paid over 11 months ago' do
      user.update(dues_last_paid_at: 11.months.ago)
      expect(user.dues_due?).to be(true)
    end
  end

  describe 'valid_instructor?' do
    it 'returns false for a nil id_expr' do
      expect(user.valid_instructor?).to be(false)
    end

    it 'returns false for a past id_expr' do
      user.update(id_expr: 1.month.ago)
      expect(user.valid_instructor?).to be(false)
    end

    it 'returns true for a future id_expr' do
      user.update(id_expr: 1.month.from_now)
      expect(user.valid_instructor?).to be(true)
    end
  end

  describe 'vessel_examiner?' do
    it 'returns false without VSC training' do
      expect(user.vessel_examiner?).to be(false)
    end

    it 'returns true with VSC training' do
      create(:course_completion, user: user, course_key: 'VSC_01', date: Time.zone.today)
      expect(user.vessel_examiner?).to be(true)
    end
  end

  describe 'cpr_aed?' do
    it 'returns false without the flag set' do
      expect(user.cpr_aed?).to be(false)
    end

    it 'returns false with a past expiration date' do
      user.update(cpr_aed_expires_at: 1.day.ago)
      expect(user.cpr_aed?).to be(false)
    end

    it 'returns true with a future expiration date' do
      user.update(cpr_aed_expires_at: 1.day.from_now)
      expect(user.cpr_aed?).to be(true)
    end
  end

  it 'returns the correct associations to include' do
    expect(described_class.position_associations).to eql(
      %i[bridge_office standing_committee_offices committees user_roles roles]
    )
  end

  describe 'api access' do
    let(:token) { user.create_token }

    describe '#token_exists?' do
      it 'exists when valid' do
        expect(user).to be_token_exists(token.new_token)
      end

      it 'does not exist when invalid' do
        expect(user).not_to be_token_exists('invalid')
      end

      it 'also finds persistent tokens' do
        token
        persistent = user.create_token(persistent: true)
        expect(user).to be_token_exists(persistent.new_token)
      end
    end

    describe '#token_expired?' do
      it 'is expired' do
        t = token.new_token
        token.update(expires_at: 5.minutes.ago)
        expect(user).to be_token_expired(t)
      end

      it 'is not expired when current' do
        expect(user).not_to be_token_expired(token.new_token)
      end
    end

    describe '#create_token' do
      it 'creates a new token' do
        expect { token }.to change { ApiToken.count }.by(1)
      end

      it 'has the new token accessible' do
        expect(token.new_token).not_to be_nil
      end

      it 'does not expose stored tokens' do
        expect(ApiToken.find(token.id).new_token).to be_nil
      end

      it 'creates persistent tokens' do
        expect(user.create_token(persistent: true).expires_at).to be_nil
      end
    end

    describe '#any_current_tokens?' do
      it 'detects temporary tokens' do
        token
        expect(user).to be_any_current_tokens
      end

      it 'detects persistent tokens' do
        user.create_token(persistent: true)
        expect(user).to be_any_current_tokens
      end
    end

    describe 'token associations' do
      let!(:at) { ApiToken.create(user: user) }
      let!(:pat) { PersistentApiToken.create(user: user) }

      it 'includes only expiring tokens' do
        expect(user.api_tokens.current).to contain_exactly(at)
      end

      it 'includes only persistent tokens' do
        expect(user.persistent_api_tokens.current).to contain_exactly(pat)
      end
    end
  end
end
