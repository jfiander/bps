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
      today = Date.today.strftime('%Y-%m-%d')
      FactoryBot.create(:user, grade: 'SN', ed_ach: '2018-01-01', life: '2017-03-05', mm: 35)
      FactoryBot.create(:user, grade: 'SN', ed_ach: '2002-01-01', life: '2001-03-05', mm: 50)
      FactoryBot.create(:user, grade: 'N',  ed_pro: '2017-01-01', senior: '2013-01-01', mm: 5)
      FactoryBot.create(:user, grade: 'JN', ed_pro: '2016-01-01', birthday: '2001-06-05')
      FactoryBot.create(:user, city: 'Someplace', state: 'ST') do |u|
        FactoryBot.create(:bridge_office, user: u, office: :commander)
        FactoryBot.create(:roster_award_recipient, user: u, year: today, award_name: 'Bill Booth Moose Milk', photo: File.new(test_image(300, 500)))
        FactoryBot.create(:roster_award_recipient, user: u, year: today, award_name: 'Master Mariner')
        FactoryBot.create(:roster_award_recipient, user: u, year: '2014-01-01', award_name: 'Bill Booth Moose Milk')
        FactoryBot.create(:roster_award_recipient, user: u, year: '2014-01-01', award_name: 'Master Mariner')
        FactoryBot.create(:roster_award_recipient, user: u, year: '2013-01-01', award_name: 'Master Mariner')
        FactoryBot.create(:roster_past_commander,  user: u, year: '2012-01-01')
        FactoryBot.create(:roster_past_commander,  user: u, year: '2015-01-01')
      end

      expect { RosterPDF.detailed }.not_to raise_error
    end
  end
end
