# frozen_string_literal: true

class EducationCertificatePDF < Prawn::Document
  MODULES ||= %w[
    Heading NameAndGrade Details Completions Seminars
  ].freeze

  MODULES.each { |c| include "EducationCertificatePDF::#{c}".constantize }

  def self.for(*args)
    EducationCertificatePDF.generate('tmp/Education_Certificate.pdf') do
      specify_font
      configure_colors
      MODULES.each { |m| send(underscore(m), *args) }
    end

    File.open('tmp/Education_Certificate.pdf', 'r+')
  end

  private

  def specify_font
    font_families.update(
      'DejaVu Sans' => {
        normal: "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf",
        bold:   "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
        italic: "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf"
      }
    )

    font 'DejaVu Sans'
  end

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

  def completion_row(row)
    y = 370 - (40 * (row - 1))
    bounding_box([0, y], width: 510, height: 40) { yield }
  end

  def completion_box(column, label, date = nil, color: 'FFFFCC')
    x = 90 * (column - 1) + 1
    bounding_box([x, 39], width: 88, height: 38) do
      stroke_bounds
      date.present? ? completed_rectangle(color) : configure_colors('CCCCCC')

      text_box label, at: [2, 35], width: 84, size: 7, align: :center, style: :bold, inline_format: true
      text_box date.to_s, at: [2, 10], width: 84, size: 7, align: :center
    end
    configure_colors
  end

  def completed_rectangle(color)
    fill_color(color)
    fill_rectangle([1, 37], 86, 36)
    configure_colors
  end
end
