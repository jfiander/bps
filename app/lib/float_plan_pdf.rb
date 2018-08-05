# frozen_string_literal: true

class FloatPlanPDF < Prawn::Document
  MODULES ||= %w[
    Heading PrimaryContact BoatInformation SafetyEquipment
    CommunicationInformation RoutePlan AlertPlan GroundTransportation
    PersonsOnboard Comments
  ].freeze

  MODULES.each { |c| include "FloatPlanPDF::#{c}".constantize }

  def self.for(float_plan)
    FloatPlanPDF.generate('tmp/run/Float_Plan.pdf') do
      configure_colors
      MODULES.each { |m| send(m.underscore, float_plan) }
    end

    File.open('tmp/run/Float_Plan.pdf', 'r+')
  end

  private

  def configure_colors(color = '232D62')
    stroke_color(color)
    fill_color(color)
  end

  def labeled_text(label, value, x1:, x2:, y:)
    draw_text "#{label}:", size: 14, at: [x1, y]
    draw_text value, size: 12, at: [x2, y]
  end
end
