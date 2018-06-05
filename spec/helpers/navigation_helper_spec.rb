# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NavigationHelper, type: :helper do
  context 'user logged in' do
    let(:user_signed_in?) { true }
    let(:current_user) { FactoryBot.create(:user) }

    it 'should generate the correct login link' do
      expect(link(:login_or_logout)).to eql(
        '<a class="red" title="Logout" rel="nofollow" data-method="delete" '\
        'href="/logout"><li class="">' \
        "<i class='far fa-sign-out' data-fa-transform='' title=''></i>" \
        'Logout</li></a>'
      )
    end

    it 'should generate the correct profile link' do
      expect(link(:profile, path: '/profile')).to eql(
        '<a class="members" title="Profile" href="/profile"><li class="">' \
        'Profile</li></a>'
      )
    end

    it 'should not show an unpermitted link' do
      expect(
        link(
          :something, path: '/something', permit: :admin, show_when: :logged_in
        )
      ).to be_nil
    end
  end

  context 'user not logged in' do
    let(:user_signed_in?) { false }

    it 'should generate the correct login link' do
      expect(link(:login_or_logout)).to eql(
        '<a class="members" title="Member Login" href="/login"><li class="">' \
        "<i class='far fa-sign-in' data-fa-transform='' title=''></i>" \
        'Member Login</li></a>'
      )
    end
  end
end
