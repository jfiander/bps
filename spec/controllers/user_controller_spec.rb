# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserController do
  let(:user) { create(:user, grade: 'N', membership_date: '2011-02-03', last_mm_year: '2015-01-01') }

  before { sign_in(user) }

  describe 'GET certificate' do
    let(:certificate_text) { PDF::Reader.new(StringIO.new(response.body)).pages.first.text }

    it 'renders a certificate PDF' do
      get(:certificate, params: { id: user.id, format: :pdf })

      expect(response).to have_http_status(:ok)
    end

    it 'includes the membership date and last merit mark year', :aggregate_failures do
      get(:certificate, params: { id: user.id, format: :pdf })

      expect(certificate_text).to include('2011-02-03')
      expect(certificate_text).to include('2015')
    end
  end
end
