# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  render_views

  describe '#not_found' do
    it 'should render the not_found template' do
      get :not_found
      expect(response).to have_http_status(:not_found)

      expect(response.body).to include("the page you requested couldn't be found")
    end
  end

  describe '#internal_server_error' do
    it 'should render the internal_server_error template' do
      get :internal_server_error
      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include('it looks like the website encountered an internal error')
    end
  end
end
