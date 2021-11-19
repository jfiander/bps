# frozen_string_literal: true

module BPS
  module PDF
    class FloatPlan
      module PrimaryContact
        def primary_contact(float_plan)
          draw_text 'Primary Contact', size: 16, at: [25, 600]
          labeled_text('Name', float_plan.name, x1: 25, x2: 85, y: 580)
          labeled_text('Phone', float_plan.phone, x1: 25, x2: 85, y: 560)
        end
      end
    end
  end
end
