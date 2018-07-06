# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseCompletion, type: :model do
  it 'should return the correct value from to_h' do
    expect(FactoryBot.create(:course_completion).to_h).to eql(
      'SE' => Date.today.beginning_of_year.strftime('%Y-%m-%d')
    )
  end
end
