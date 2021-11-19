# frozen_string_literal: true

module BPS
  module PDF
    class Roster
      class Detailed
        module Flags
          def flags
            load_burgee
            load_ensign
            stroke_line([0, 390], [325, 390])
            ensign
            burgee
          end

        private

          def ensign
            insert_image 'tmp/run/Ensign.png', at: [0, 350], width: 150
            flag_text(config_text[:flags][:ensign], 350)
          end

          def burgee
            insert_image 'tmp/run/Burgee.png', at: [0, 200], width: 150
            flag_text(config_text[:flags][:burgee], 200, 175)
          end

          def flag_text(text, y_pos, height = 100)
            bounding_box([175, y_pos], width: 150, height: height) do
              formatted_text(
                [{ text: text }], size: BPS::PDF::Roster::Detailed::BODY_REG_SIZE, align: :justify
              )
            end
          end
        end
      end
    end
  end
end
