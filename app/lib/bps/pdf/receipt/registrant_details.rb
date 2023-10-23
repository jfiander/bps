# frozen_string_literal: true

module BPS
  module PDF
    class Receipt
      module RegistrantDetails
        # This module defines no public methods.
        def _; end

      private

        def registrant_details(payment)
          return unless show_details?(payment)

          start_new_page
          bounding_box([0, 725], width: 550, height: 50) do
            text 'Registrant Details', size: 24, style: :bold, align: :center
          end

          registrants(payment).each_with_index do |registration, index|
            height = 50
            height += 10 * registration.registration_options.count
            top = 675 - (index * height)
            bounding_box([0, top], width: 550, height: height) do
              registrant(registration)
              registration_options(registration)
            end
          end

          policy_links(nil) # Ensure policy links are on all pages
        end

        def show_details?(payment)
          return false unless payment.parent.is_a?(Registration)

          payment.parent.additional_registrations.any? || payment.parent.registration_options.any?
        end

        def registrants(payment)
          @registrants ||=
            [payment.parent] + payment.parent.additional_registrations
        end

        def registrant(registration)
          text(
            "<b>#{registration.user&.full_name || registration.email}</b>",
            size: 14, align: :left, inline_format: true
          )
        end

        def registration_options(registration)
          registration.registration_options.each do |option|
            move_down 5
            text(
              "<b>#{option.description}</b>: #{option.name}",
              size: 14, align: :left, inline_format: true, indent_paragraphs: 30
            )
          end
        end
      end
    end
  end
end
