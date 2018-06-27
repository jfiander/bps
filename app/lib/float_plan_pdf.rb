# frozen_string_literal: true

class FloatPlanPDF < Prawn::Document
  MODULES ||= %w[
    Heading PrimaryContact BoatInformation SafetyEquipment
    CommunicationInformation RoutePlan AlertPlan GroundTransportation
    PersonsOnboard Comments
  ].freeze

  MODULES.each { |c| include "FloatPlanPDF::#{c}".constantize }

  def self.for(float_plan)
    FloatPlanPDF.generate('tmp/Float_Plan.pdf') do
      configure_colors
      MODULES.each { |m| send(underscore(m), float_plan) }
    end

    File.open('tmp/Float_Plan.pdf', 'r+')
  end

  private

  def configure_colors(color = '232D62')
    stroke_color(color)
    fill_color(color)
  end

  def underscore(string)
    string.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
  end
end
