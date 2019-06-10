# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FloatPlan, type: :model do
  context 'with default factory' do
    before do
      @float_plan = FactoryBot.create(:float_plan, :one_onboard)
    end

    it 'successfullies generate a PDF' do
      expect { @float_plan.generate_pdf }.not_to raise_error
    end

    it 'successfullies generate a PDF with a radio comment' do
      @float_plan.radio = 'VHF'
      expect { @float_plan.generate_pdf }.not_to raise_error
    end

    it 'successfullies generate a PDF with an alert phone' do
      @float_plan.alert_phone = '555-555-5555'
      expect { @float_plan.generate_pdf }.not_to raise_error
    end

    it 'generates a correct link' do
      expect(@float_plan.link).to match(%r{https://floatplans.development.bpsd9.org/\d+.pdf})
    end
  end

  it 'successfullies generate a PDF with engines' do
    @float_plan = FactoryBot.create(:float_plan_with_engines)
    expect { @float_plan.generate_pdf }.not_to raise_error
  end

  it 'successfullies generate a PDF with a trailer plate' do
    @float_plan = FactoryBot.create(:float_plan_with_trailer)
    expect { @float_plan.generate_pdf }.not_to raise_error
  end

  it 'successfullies generate a PDF with a car' do
    @float_plan = FactoryBot.create(:float_plan_with_car)
    expect { @float_plan.generate_pdf }.not_to raise_error
  end
end
