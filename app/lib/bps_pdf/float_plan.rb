# frozen_string_literal: true

module BpsPdf
  class FloatPlan < BpsPdf::Base
    MODULES ||= %w[
      Heading PrimaryContact BoatInformation SafetyEquipment
      CommunicationInformation RoutePlan AlertPlan GroundTransportation
      Comments PersonsOnboard
    ].freeze

    MODULES.each { |c| include "BpsPdf::FloatPlan::#{c}".constantize }

    def self.for(float_plan)
      path = BpsPdf::FloatPlan.generate('Float_Plan') do
        configure_colors
        MODULES.each { |m| send(m.underscore, float_plan) }
      end

      File.open(path, 'r+')
    end

  private

    def labeled_text(label, value, x1:, x2:, y:)
      draw_text "#{label}:", size: 14, at: [x1, y]
      draw_text value, size: 12, at: [x2, y]
    end

    def bounded_text(label, value, **options)
      options[:split] ||= 40
      height = (value.to_s.length.to_f / options[:split]).ceil

      draw_text "#{label}:", size: 14, at: [options[:x1], options[:y]]
      bounded_box_value(value, height, options)

      height
    end

    def bounded_box_value(value, height, **options)
      value_with_spaces = value.to_s.gsub(/,([^\s])/, ', \1')

      bounding_box([options[:x2], options[:y] + 8], width: 150, height: (15 * height)) do
        text value_with_spaces
      end
    end
  end
end
