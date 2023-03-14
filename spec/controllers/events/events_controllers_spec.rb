# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::EventsController do
  let(:event_type) { 'event' }

  it 'renders the schedule view' do
    get :schedule

    expect(response).to render_template('event/schedule')
  end
end
