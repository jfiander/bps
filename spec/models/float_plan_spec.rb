# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FloatPlan, type: :model do
  before(:each) do
    @float_plan = FactoryBot.create(:float_plan, :one_onboard)
  end

  it 'should successfully generate a PDF' do
    expect { @float_plan.generate_pdf }.not_to raise_error
  end

  it 'should generate a correct link' do
    expect(@float_plan.link).to match(
      %r{https://floatplans.development.bpsd9.org/\d+.pdf}
    )
  end
end
