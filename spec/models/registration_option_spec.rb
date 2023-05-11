# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationOption do
  let(:user) { create(:user) }

  let(:event) { create(:event) }
  let(:event_selection) { create(:event_selection, event: event, description: 'An Option') }
  let!(:event_option) { create(:event_option, event_selection: event_selection, name: 'One') }

  let(:registration) { create(:registration, event: event, user: user) }

  let(:other_event) { create(:event) }
  let(:other_event_selection) { create(:event_selection, event: other_event, description: 'Different Option') }
  let!(:other_event_option) { create(:event_option, event_selection: other_event_selection, name: 'Two') }

  it 'delegates description to the event_selection' do
    reg_opt = build(:registration_option, registration: registration, event_option: event_option)

    expect(reg_opt.description).to eq(event_option.event_selection.description)
  end

  describe 'validations' do
    it 'validates options belong to a selection for the current event' do
      reg_opt = build(:registration_option, registration: registration, event_option: event_option)

      expect(reg_opt).to be_valid
    end

    it 'adds a model error for options that belong to a selection for a different event' do
      reg_opt = build(:registration_option, registration: registration, event_option: other_event_option)

      expect(reg_opt).not_to be_valid
    end
  end
end
