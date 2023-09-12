# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NavigationHelper do
  context 'with user logged in' do
    let(:user_signed_in?) { true }
    let(:current_user) { create(:user) }

    it 'generates the correct login link' do
      expect(link('login_or_logout')).to eql(
        '<a class="red" title="Logout" rel="nofollow" data-method="delete" href="/logout"><li class=" nav-with-icon">' \
        '<div class="nav-icon-contents">' \
        "<i class='fad fa-sign-out fa-1x' id='' style='' data-fa-transform='' title=''></i>Logout</div></li></a>"
      )
    end

    it 'generates the correct profile link' do
      expect(link('Profile', path: '/profile', show_when: 'logged_in')).to eql(
        '<a class="members" title="Profile" href="/profile"><li class="">Profile</li></a>'
      )
    end

    it 'generates the correct admin link' do
      expect(link('Something', path: '/something', admin: true)).to eql(
        '<a class="admin" title="Something" href="/something"><li class="admin">Something</li></a>'
      )
    end

    it 'does not show an unpermitted link' do
      expect(link('Something', path: '/something', permit: :admin, show_when: 'logged_in')).to be_nil
    end
  end

  context 'with user not logged in' do
    let(:user_signed_in?) { false }

    it 'generates the correct login link' do
      expect(link('login_or_logout')).to eql(
        '<a class="members" title="Member Login" href="/login"><li class=" nav-with-icon">' \
        '<div class="nav-icon-contents">' \
        "<i class='fad fa-sign-in fa-1x' id='' style='' data-fa-transform='' title=''></i>" \
        'Member Login</div></li></a>'
      )
    end
  end
end
