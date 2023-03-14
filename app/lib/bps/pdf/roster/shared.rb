# frozen_string_literal: true

module BPS
  module PDF
    class Roster
      module Shared
        # This module defines no public methods.
        def _; end

      private

        def load_burgee
          burgee = BPS::S3.new(:static).download('flags/Birmingham/Birmingham.png')
          File.write('tmp/run/Burgee.png', burgee)
        end

        def load_ensign
          ensign = BPS::S3.new(:static).download('flags/PNG/ENSIGN.500.png')
          File.write('tmp/run/Ensign.png', ensign)
        end

        def format_name(name)
          if name.to_s&.match?(%r{1st/Lt})
            pre, name = name.split('1st/Lt')
            [{ text: "#{pre}1" }, { text: 'st', styles: [:superscript] }, { text: "/Lt#{name}" }]
          else
            [{ text: name }]
          end
        end
      end
    end
  end
end
