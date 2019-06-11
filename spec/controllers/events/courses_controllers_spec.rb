# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::CoursesController, type: :controller do
  let(:event_type) { 'course' }

  it 'renders the schedule view' do
    get :schedule

    expect(response).to render_template('event/schedule')
  end

  it 'renders the catalog view' do
    get :catalog

    expect(response).to render_template('event/catalog')
  end
end
