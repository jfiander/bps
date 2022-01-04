# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseCompletion, type: :model do
  it 'returns the correct value from to_h' do
    expect(FactoryBot.create(:course_completion).to_h).to eql(
      'SE' => Time.zone.today.beginning_of_year.strftime('%Y-%m-%d')
    )
  end

  it 'returns a valid course completions hash for a user' do
    user = FactoryBot.create(:user)
    date = Date.strptime('2018-07-01', '%Y-%m-%d')
    FactoryBot.create(:course_completion, user: user, date: date, course_key: 'SE')
    FactoryBot.create(:course_completion, user: user, date: date + 1.month, course_key: 'PI')
    FactoryBot.create(:course_completion, user: user, date: date + 2.months, course_key: 'AP')

    expect(user.completions).to eql('SE' => '2018-07-01', 'PI' => '2018-08-01', 'AP' => '2018-09-01')
  end

  describe 'for_year' do
    subject(:completions) { CourseCompletion.for_year(2021) }

    let(:user) { FactoryBot.create(:user) }

    before do
      FactoryBot.create(:course_completion, user: user, date: '20201231', course_key: 'SE')
      FactoryBot.create(:course_completion, user: user, date: '20210315', course_key: 'PI')
      FactoryBot.create(:course_completion, user: user, date: '20220101', course_key: 'AP')
    end

    it 'filters by year', :aggregate_failures do
      expect(completions.count).to eq(1)
      expect(completions.first.course_key).to eq('PI')
    end
  end
end
