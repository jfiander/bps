# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BPS::PDF::Roster, type: :lib do
  context 'with a default user' do
    before do
      create_list(:user, 15)
      create(:user, rank: '1/Lt')
      create(:user, email: 'nobody-1234567890@bpsd9.org')
    end

    it 'successfullies generate a portrait roster' do
      expect { described_class.portrait }.not_to raise_error
    end

    it 'successfullies generate a landscape roster' do
      expect { described_class.landscape }.not_to raise_error
    end

    it 'successfullies generate a landscape roster with a blank page' do
      expect { described_class.landscape(include_blank: true) }.not_to raise_error
    end

    it 'successfullies generate a detailed roster', slow: true do
      today = Time.zone.today.strftime('%Y-%m-%d')
      create(:user, grade: 'SN', ed_ach: '2018-01-01', life: '2017-03-05', mm: 35)
      create(:user, grade: 'SN', ed_ach: '2002-01-01', life: '2001-03-05', mm: 50)
      create(:user, grade: 'N',  ed_pro: '2017-01-01', senior: '2013-01-01', mm: 5)
      create(:user, grade: 'JN', ed_pro: '2016-01-01', birthday: '2001-06-05')
      create(:user, city: 'Someplace', state: 'ST') do |u|
        create(:bridge_office, user: u, office: :commander)
        create(
          :roster_award_recipient,
          user: u, year: today, award_name: 'Bill Booth Moose Milk', photo: File.new(test_image(300, 500))
        )
        create(:roster_award_recipient, user: u, year: today, award_name: 'Master Mariner')
        create(:roster_award_recipient, user: u, year: '2014-01-01', award_name: 'Bill Booth Moose Milk')
        create(:roster_award_recipient, user: u, year: '2014-01-01', award_name: 'Master Mariner')
        create(:roster_award_recipient, user: u, year: '2013-01-01', award_name: 'Master Mariner')
        create(:roster_past_commander,  user: u, year: '2012-01-01')
        create(:roster_past_commander,  user: u, year: '2015-01-01')
      end

      expect { described_class.detailed }.to output(/\*\*\* Roster generation complete!/).to_stdout_from_any_process
    end
  end
end
