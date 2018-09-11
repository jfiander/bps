# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CodeList, type: :lib do
  it 'should include a valid seminar' do
    expect(CodeList.new.seminars).to include(
      'name' => 'Sail Trim', 'code' => 'SAILTR'
    )
  end

  it 'should include a valid course' do
    expect(CodeList.new.courses).to include(
      'name' => 'Navigation', 'code' => 'N', 'exam_prefix' => 'NA'
    )
  end
end
