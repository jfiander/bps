# frozen_string_literal: true

module BpsPdf
  class FloatPlan
    module PersonsOnboard
      def persons_onboard(float_plan)
        configure_colors('000099')
        if float_plan.onboard.count > 2
          new_page_for_onboards(float_plan)
        else
          same_page_onboards(float_plan)
        end
        configure_colors
      end

    private

      def same_page_onboards(float_plan)
        @onboard_y = @safety_y - 50
        @onboard_x = 300

        draw_text 'Persons Onboard', size: 16, at: [@onboard_x, @safety_y - 30]
        float_plan.onboard.each { |person| person_onboard(person) }
      end

      def new_page_for_onboards(float_plan)
        start_new_page

        @onboard_y = 750
        @onboard_x = 0

        bounding_box([0, 720], width: 500, height: 720) do
          text 'Persons Onboard', size: 16
          move_down 10
          float_plan.onboard.each { |person| person_onboard_new_page(person) }
        end
      end

      def person_onboard(person)
        draw_text "#{person.name} (#{person.age})", size: 12, at: [300, @onboard_y]
        if person.phone.present?
          @onboard_y -= 20
          draw_text person.phone, size: 12, at: [320, @onboard_y]
        end
        if person.address.present?
          @onboard_y -= 20
          draw_text person.address, size: 12, at: [320, @onboard_y]
        end
        @onboard_y -= 20
      end

      def person_onboard_new_page(person)
        text "#{person.name} (#{person.age})", size: 12
        text person.phone, size: 12 if person.phone.present?
        text person.address, size: 12 if person.address.present?
        move_down 10
      end
    end
  end
end
