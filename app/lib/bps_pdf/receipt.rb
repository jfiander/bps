# frozen_string_literal: true

module BpsPdf
  class Receipt < BpsPdf::Base
    MODULES ||= %w[
      CustomerInfo TransactionInfo Cost PolicyLinks
    ].freeze

    MODULES.each { |c| include "BpsPdf::Receipt::#{c}".constantize }

    def self.create_pdf(payment)
      BpsPdf::Receipt.generate('tmp/run/Receipt.pdf') do
        specify_font_awesome
        specify_font
        configure_colors
        load_logo

        insert_image('tmp/run/ABC-B.png', at: [0, 725], width: 550)
        title

        MODULES.each { |m| send(m.underscore, payment) }
      end

      File.open('tmp/run/Receipt.pdf', 'r+')
    end

  private

    def title
      bounding_box([0, 625], width: 550, height: 35) do
        text 'Transaction Receipt', size: 24, style: :bold, align: :center
      end
    end
  end
end
