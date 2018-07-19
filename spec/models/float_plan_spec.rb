# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FloatPlan, type: :model do
  context 'with default factory' do
    before(:each) do
      @float_plan = FactoryBot.create(:float_plan, :one_onboard)
    end

    it 'should successfully generate a PDF' do
      expect { @float_plan.generate_pdf }.not_to raise_error
    end

    it 'should successfully generate a PDF with a radio comment' do
      @float_plan.radio = 'VHF'
      expect { @float_plan.generate_pdf }.not_to raise_error
    end

    it 'should generate a correct link' do
      expect(@float_plan.link).to match(
        %r{https://floatplans.development.bpsd9.org/\d+.pdf}
      )
    end
  end

  it 'should successfully generate a PDF with a trailer plate' do
    @float_plan = FactoryBot.create(:float_plan_with_trailer)
    expect { @float_plan.generate_pdf }.not_to raise_error
  end

  it 'should successfully generate a PDF with a car' do
    @float_plan = FactoryBot.create(:float_plan_with_car)
    expect { @float_plan.generate_pdf }.not_to raise_error
  end
end
