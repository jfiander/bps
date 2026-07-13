# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::PasswordsController do
  render_views

  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  let(:user) { create(:user) }

  describe 'POST create' do
    it 'sends reset instructions when reCAPTCHA passes' do
      expect { post(:create, params: { user: { email: user.email } }) }
        .to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to have_http_status(:found)
    end

    it 'does not send reset instructions when reCAPTCHA fails' do
      allow(controller).to receive(:verify_recaptcha).and_return(false)

      expect { post(:create, params: { user: { email: user.email } }) }
        .not_to(change { ActionMailer::Base.deliveries.count })

      expect(response).to redirect_to(new_user_password_path)
    end
  end
end
