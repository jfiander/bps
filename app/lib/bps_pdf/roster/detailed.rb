# frozen_string_literal: true

class BpsPdf::Roster::Detailed < BpsPdf::Base
  include  BpsPdf::Roster::Shared
  include  BpsPdf::Roster::Detailed::Helpers

  MODULES ||= %w[
    Cover Flags Bridge Merit Awards PastAwards PastCommanders EdAwards Benefits
    RosterInfo Directory
  ].freeze

  TITLE_SIZE ||= 16
  SUBTITLE_SIZE ||= 14
  SECTION_TITLE_SIZE ||= 11
  HEADING_SIZE ||= 9
  BODY_REG_SIZE ||= 8
  BODY_SM_SIZE ||= 7

  MODULES.each { |c| include "BpsPdf::Roster::Detailed::#{c}".constantize }

  def self.create_pdf
    BpsPdf::Roster::Detailed.generate('tmp/run/Roster.pdf', page_size: [396, 612]) do
      specify_font
      configure_colors

      MODULES.each do |m|
        puts "*** Generating #{m}..."
        send(m.underscore)
      end
      puts '*** Roster generation complete!'
    end

    File.open('tmp/run/Roster.pdf', 'r+')
  end
end
