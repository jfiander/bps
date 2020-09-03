# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CodeList, type: :lib do
  it 'includes a valid seminar' do
    expect(described_class.new.seminars).to include('name' => 'Sail Trim', 'code' => 'SAILTR')
  end

  it 'includes a valid course' do
    expect(described_class.new.courses).to include('name' => 'Navigation', 'code' => 'N', 'exam_prefix' => 'NA')
  end
end
