# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::CoursesController do
  let(:event_type) { 'course' }

  it 'renders the schedule view' do
    get :schedule

    expect(response).to render_template('event/schedule')
  end

  it 'renders the catalog view' do
    get :catalog

    expect(response).to render_template('event/catalog')
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    before do
      admin = create(:role, name: 'admin')
      create(:role, name: 'course', parent: admin)
      user.permit!(:course)
      sign_in(user)
    end

    it 'accepts a standard single-hash event submission and updates the record' do
      patch :update, params: {
        event: {
          id: event.id,
          event_type_id: event.event_type_id,
          description: 'Updated description',
          event_selections: ''
        },
        includes: '', topics: '', instructors: ''
      }

      expect(response).not_to have_http_status(:bad_request)
      expect(response).to redirect_to(courses_path)
      expect(event.reload.description).to eq('Updated description')
    end
  end
end
