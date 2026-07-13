# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController do
  before { generic_seo_and_ao }

  let(:event) { create(:event) }

  def params
    { registration: { event_id: event.id, name: 'Someone', email: 'someone@example.com' } }
  end

  describe 'POST create' do
    context 'when anonymous' do
      it 'registers when reCAPTCHA passes' do
        expect { post(:create, params: params) }.to change(Registration, :count).by(1)

        expect(response).to have_http_status(:found)
      end

      it 'does not register when reCAPTCHA fails' do
        allow(controller).to receive(:verify_recaptcha).and_return(false)

        expect { post(:create, params: params) }.not_to change(Registration, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when signed in' do
      let(:user) { create(:user) }

      before { sign_in(user) }

      it 'registers without requiring reCAPTCHA' do
        allow(controller).to receive(:verify_recaptcha).and_return(false)

        expect { post(:create, params: params) }.to change(Registration, :count).by(1)

        expect(response).to have_http_status(:found)
      end
    end
  end
end
