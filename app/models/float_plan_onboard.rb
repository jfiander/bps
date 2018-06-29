class FloatPlanOnboard < ApplicationRecord
  belongs_to :float_plan

  default_scope { order(created_at: :asc) }
end
