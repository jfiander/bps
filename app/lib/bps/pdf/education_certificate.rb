# frozen_string_literal: true

module BPS
  module PDF
    class EducationCertificate < Base
      MODULES = %w[
        Heading NameAndGrade Details Completions Seminars
      ].freeze

      ROW_HEIGHT = 36
      COLUMN_WIDTH = 90

      MODULES.each { |c| include "BPS::PDF::EducationCertificate::#{c}".constantize }

      def self.for(*args)
        path = BPS::PDF::EducationCertificate.generate('Education_Certificate') do
          specify_font
          configure_colors
          MODULES.each { |m| send(m.underscore, *args) }
        end

        File.open(path, 'r+')
      end

    private

      def completion_row(row, &block)
        y = 390 - (ROW_HEIGHT * (row - 1))
        bounding_box([0, y], width: 510, height: ROW_HEIGHT, &block)
      end

      def completion_box(column, label, date = nil, color: 'FFFFCC')
        x = (COLUMN_WIDTH * (column - 1)) + 1
        bounding_box([x, (ROW_HEIGHT - 1)], width: (COLUMN_WIDTH - 2), height: (ROW_HEIGHT - 2)) do
          stroke_bounds
          date.present? ? completed_rectangle(color) : configure_colors('CCCCCC')
          completion_contents(label, date)
        end
        configure_colors
      end

      def completion_contents(label, date)
        text_box(
          label,
          at: [2, (ROW_HEIGHT - 5)], width: (COLUMN_WIDTH - 6), size: 7, align: :center,
          style: :bold, inline_format: true
        )
        text_box date.to_s, at: [2, 10], width: (COLUMN_WIDTH - 6), size: 7, align: :center
      end

      def completed_rectangle(color)
        fill_color(color)
        fill_rectangle([1, (ROW_HEIGHT - 3)], (COLUMN_WIDTH - 4), (ROW_HEIGHT - 4))
        configure_colors
      end
    end
  end
end
