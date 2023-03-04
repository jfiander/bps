# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateHelper do
  describe 'ExCom' do
    it 'correctlies determine if ExCom is in session' do
      expect(excom_in_session?(Date.strptime('2018-01-01'))).to be(true)
    end

    it 'correctlies determine if ExCom is in recess' do
      expect(excom_in_session?(Date.strptime('2018-07-01'))).to be(false)
    end

    it 'selects the correct next date for the current month' do
      expect(next_excom(Date.strptime('2018-06-01')).to_date).to eql(Date.strptime('2018-06-05'))
    end

    it 'selects the correct date for the next month' do
      expect(next_excom(Date.strptime('2018-05-02')).to_date).to eql(Date.strptime('2018-06-05'))
    end

    it 'selects the correct end-of-summer date' do
      expect(next_excom(Date.strptime('2018-06-15')).to_date).to eql(Date.strptime('2018-09-04'))
    end

    it 'selects the correct start-of-year date' do
      expect(next_excom(Date.strptime('2019-12-20')).to_date).to eql(Date.strptime('2020-01-07'))
    end

    it 'selects the correct start-of-year date when the year starts on a Tuesday' do
      expect(next_excom(Date.strptime('2018-12-20')).to_date).to eql(Date.strptime('2019-01-08'))
    end

    it 'selects the correct date for a meeting day' do
      expect(next_excom(Date.strptime('2018-06-05')).to_date).to eql(Date.strptime('2018-06-05'))
    end
  end

  describe 'Membership' do
    it 'selects the correct date for the current month' do
      expect(next_membership(Date.strptime('2018-04-01')).to_date).to eql(Date.strptime('2018-04-10'))
    end

    it 'selects the correct date during the week after an ExCom' do
      expect(next_membership(Date.strptime('2018-04-05')).to_date).to eql(Date.strptime('2018-04-10'))
    end

    it 'selects the correct date for the next month' do
      expect(next_membership(Date.strptime('2018-04-15')).to_date).to eql(Date.strptime('2018-05-08'))
    end

    it 'selects the correct end-of-summer date' do
      expect(next_membership(Date.strptime('2018-05-15')).to_date).to eql(Date.strptime('2018-09-11'))
    end

    it 'selects the correct start-of-year date' do
      expect(next_membership(Date.strptime('2019-12-20')).to_date).to eql(Date.strptime('2020-01-14'))
    end

    it 'selects the correct start-of-year date when the year starts on a Tuesday' do
      expect(next_membership(Date.strptime('2018-12-20')).to_date).to eql(Date.strptime('2019-01-15'))
    end

    it 'selects the correct date for a meeting day' do
      expect(next_membership(Date.strptime('2018-05-08')).to_date).to eql(Date.strptime('2018-05-08'))
    end
  end
end
