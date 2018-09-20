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

    it 'should successfully generate a landscape roster with a blank page' do
      expect { RosterPDF.landscape(include_blank: true) }.not_to raise_error
    end

    it 'should successfully generate a detailed roster' do
      FactoryBot.create(:user, life: '2017-03-05', grade: 'SN', ed_ach: '2018-01-01', mm: 35)
      FactoryBot.create(:user, life: '2001-03-05', grade: 'SN', ed_ach: '2002-01-01', mm: 50)
      FactoryBot.create(:user, grade: 'N', ed_pro: '2017-01-01', senior: '2013-01-01', mm: 5)
      FactoryBot.create(:user, grade: 'JN', ed_pro: '2016-01-01')
      u = FactoryBot.create(:user, city: 'Someplace', state: 'ST')
      FactoryBot.create(:bridge_office, office: :commander, user: u)
      FactoryBot.create(:award_recipient, award_name: 'Bill Booth Moose Milk', user: u, year: Date.today.strftime('%Y-%m-%d'), photo: File.new(test_image(300, 500)))
      FactoryBot.create(:award_recipient, award_name: 'Master Mariner', user: u, year: Date.today.strftime('%Y-%m-%d'))
      FactoryBot.create(:award_recipient, award_name: 'Bill Booth Moose Milk', user: u, year: '2014-01-01')
      FactoryBot.create(:award_recipient, award_name: 'Master Mariner', user: u, year: '2014-01-01')
      FactoryBot.create(:award_recipient, award_name: 'Master Mariner', user: u, year: '2013-01-01')
      FactoryBot.create(:past_commander, user: u, year: '2012-01-01')
      FactoryBot.create(:past_commander, user: u, year: '2015-01-01')

      expect { RosterPDF.detailed }.not_to raise_error
    end
  end
end
