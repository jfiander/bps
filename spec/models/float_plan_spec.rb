# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FloatPlan do
  context 'with default factory' do
    let(:float_plan) { create(:float_plan, :one_onboard) }

    it 'successfully generates a PDF' do
      expect { float_plan.generate_pdf }.not_to raise_error
    end

    it 'successfully generates a PDF with a radio comment' do
      float_plan.radio = 'VHF'
      expect { float_plan.generate_pdf }.not_to raise_error
    end

    it 'successfully generates a PDF with an alert phone' do
      float_plan.alert_phone = '555-555-5555'
      expect { float_plan.generate_pdf }.not_to raise_error
    end

    it 'generates a correct link' do
      expect(float_plan.link).to match(%r{https://floatplans.development.bpsd9.org/\d+.pdf})
    end

    it 'successfully generates a PDF with three onboard' do
      2.times do
        float_plan.float_plan_onboards << create(
          :float_plan_onboard, float_plan: float_plan
        )
      end

      expect { float_plan.generate_pdf }.not_to raise_error
    end
  end

  it 'successfully generates a PDF with engines' do
    float_plan = create(:float_plan_with_engines)
    expect { float_plan.generate_pdf }.not_to raise_error
  end

  it 'successfully generates a PDF with a trailer plate' do
    float_plan = create(:float_plan_with_trailer)
    expect { float_plan.generate_pdf }.not_to raise_error
  end

  it 'successfully generates a PDF with a car' do
    float_plan = create(:float_plan_with_car)
    expect { float_plan.generate_pdf }.not_to raise_error
  end

  it 'does not return an error on invalidate!' do
    float_plan = create(:float_plan, :one_onboard)
    expect { float_plan.invalidate! }.not_to raise_error
  end
end
