# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController do
  render_views

  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  let(:user) { create(:user, password: 'Password1!', password_confirmation: 'Password1!') }

  describe 'POST create' do
    it 'signs in when reCAPTCHA passes' do
      post(:create, params: { user: { email: user.email, password: 'Password1!' } })

      expect(controller.current_user).to eq(user)
    end

    it 'does not authenticate when reCAPTCHA fails' do
      allow(controller).to receive(:verify_recaptcha).and_return(false)

      post(:create, params: { user: { email: user.email, password: 'Password1!' } })

      expect(response).to redirect_to(new_user_session_path)
      expect(controller.current_user).to be_nil
      expect(session.keys).not_to include('warden.user.user.key')
    end
  end
end
