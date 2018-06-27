class FloatPlan < ApplicationRecord
  has_many :float_plan_onboards
  accepts_nested_attributes_for :float_plan_onboards

  validates :float_plan_onboards, presence: true

  after_create { generate_pdf }

  has_attached_file(
    :pdf,
    paperclip_defaults(:files).merge(path: 'float_plans/:id/float_plan.pdf')
  )

  validates_attachment_content_type(:pdf, content_type: %r{\Aapplication/pdf\z})

  def onboard
    float_plan_onboards
  end

  def generate_pdf
    update!(pdf: FloatPlanPDF.for(self))
  end

  def link
    FloatPlan.buckets[:floatplans].link("#{id}/float_plan.pdf")
  end

  def fuel
    if fuel_capacity.present?
      "#{fuel_capacity} gallons"
    else
      'n/a'
    end
  end

  def engines
    if engines?
      [
        number_of_engines,
        [engine_types, hp].reject(&:blank?).join(' – ')
      ].join(' ')
    else
      'n/a'
    end
  end

  def boat_type_display
    "#{boat_type}#{subtype.present? ? " (#{subtype})" : ''}"
  end

  private

  def engines?
    number_of_engines.present? || 
      engine_type_1.present? ||
      engine_type_2.present? ||
      horse_power.present?
  end

  def engine_types
    engine_types = [engine_type_1, engine_type_2].reject(&:blank?).join(' / ')
    engine_types.present? ? "(#{engine_types})" : nil
  end

  def hp
    horse_power.present? ? "#{horse_power} HP" : nil
  end
end
