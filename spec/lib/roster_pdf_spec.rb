# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RosterPDF, type: :lib do
  context 'default user' do
    before(:each) do
      FactoryBot.create_list(:user, 15)
      FactoryBot.create(:user, rank: '1/Lt')
      FactoryBot.create(:user, email: 'nobody-1234567890@bpsd9.org')
    end

    it 'should successfully generate a portrait roster' do
      expect { RosterPDF.portrait }.not_to raise_error
    end

    it 'should successfully generate a landscape roster' do
      expect { RosterPDF.landscape }.not_to raise_error
    end
  end
end
