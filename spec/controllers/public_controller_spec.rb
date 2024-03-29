# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicController do
  before { generic_seo_and_ao }

  render_views

  it 'correctlies render the general structure' do
    get :home
    expect(response).to have_http_status(:ok)

    expect(response.body).to match(/For Boaters, By Boaters/)
  end

  describe 'META tags' do
    it 'renders the title tag' do
      get :home

      expect(response.body).to match(%r{<title>America&#39;s Boating Club – Birmingham Squadron</title>})
    end

    it 'renders the description tag' do
      get :home

      expect(response.body).to match(%r{<meta[^>]*?name="description" />})
    end

    it 'renders the keywords tag' do
      get :home

      expect(response.body).to match(%r{<meta[^>]*?name="keywords" />})
    end
  end

  describe 'registering' do
    def params(event)
      { registration: { event_id: event.id, email: 'someone@example.com' }, format: :js }
    end

    context 'when accepting registrations' do
      before do
        @event = create(:event)
      end

      it 'allows registering to a registerable event' do
        post :register, params: params(@event)

        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct error response for an already-registered event' do
        create(:registration, event: @event, email: 'someone@example.com')

        post :register, params: params(@event)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eql('You are already registered.')
      end
    end

    it 'does not allow registering to a closed event' do
      event = create(:event, :not_public_registerable)

      post :register, params: params(event)

      expect(response).to redirect_to(courses_path(id: event.id))
    end
  end
end
