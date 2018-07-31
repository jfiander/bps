# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublicController, type: :controller do
  render_views

  it 'should correctly render the general structure' do
    get :home
    expect(response).to have_http_status(:ok)

    expect(response.body).to match(
      /Come for the Boating Education/
    )
  end

  describe 'META tags' do
    it 'should render the title tag' do
      get :home

      expect(response.body).to match(
        %r{<title>America&#39;s Boating Club – Birmingham Squadron</title>}
      )
    end

    it 'should render the description tag' do
      get :home

      expect(response.body).to match(%r{<meta[^>]*?name="description" />})
    end

    it 'should render the keywords tag' do
      get :home

      expect(response.body).to match(%r{<meta[^>]*?name="keywords" />})
    end
  end

  describe 'registering' do
    def params(event)
      {
        registration: { event_id: event.id, email: 'someone@example.com' },
        format: :js
      }
    end

    context 'accepting registrations' do
      before(:each) do
        @event = FactoryBot.create(:event)
        FactoryBot.create(:bridge_office, office: 'educational')
      end

      it 'allows registering to a registerable event' do
        post :register, params: params(@event)

        expect(response).to have_http_status(:ok)
      end

      it 'allows registering to a registerable event' do
        FactoryBot.create(
          :registration, event: @event, email: 'someone@example.com'
        )

        post :register, params: params(@event)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eql(
          'You are already registered for this course.'
        )
      end
    end

    it 'does not allow registering to a closed event' do
      event = FactoryBot.create(:event, :not_public_registerable)

      post :register, params: params(event)

      expect(response).to redirect_to(courses_path(id: event.id))
    end
  end
end
