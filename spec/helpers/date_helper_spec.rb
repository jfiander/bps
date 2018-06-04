# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateHelper, type: :helper do
  it 'should correctly determine if ExCom is in session' do
    expect(excom_in_session?(Date.strptime('2018-01-01'))).to be(true)
  end

  it 'should correctly determine if ExCom is in recess' do
    expect(excom_in_session?(Date.strptime('2018-07-01'))).to be(false)
  end

  it 'should select the correct next date for the current month' do
    expect(next_excom(Date.strptime('2018-06-01')).to_date).to eql(
      Date.strptime('2018-06-05')
    )
  end

  it 'should select the correct date for the next month' do
    expect(next_excom(Date.strptime('2018-05-02')).to_date).to eql(
      Date.strptime('2018-06-05')
    )
  end

  it 'should select the correct end-of-summer date' do
    expect(next_excom(Date.strptime('2018-06-06')).to_date).to eql(
      Date.strptime('2018-09-04')
    )
  end
end
