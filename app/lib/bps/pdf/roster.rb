# frozen_string_literal: true

module BPS
  module PDF
    class Roster < Base
      include  BPS::PDF::Roster::Shared
      include  BPS::PDF::Roster::Simple::CoverPage
      include  BPS::PDF::Roster::Simple::RosterPages

      def self.create_pdf(orientation = :portrait, include_blank: false)
        @orientation = orientation
        size = [612, page_width]
        path = BPS::PDF::Roster.generate('Roster', page_layout: @orientation, page_size: size) do
          specify_font
          configure_colors

          cover_page(orientation, include_blank: include_blank)
          roster_pages(User.unlocked.alphabetized, orientation)
        end

        File.open(path, 'r+')
      end

      def self.portrait(_ignored = nil)
        create_pdf(:portrait)
      end

      def self.landscape(include_blank: false)
        create_pdf(:landscape, include_blank: include_blank)
      end

      def self.detailed(*_ignored)
        BPS::PDF::Roster::Detailed.create_pdf
      end

      def self.page_width
        792 / (@orientation == :landscape ? 2 : 1)
      end

    private

      def config
        @config ||= YAML.safe_load(
          File.read("#{Rails.root}/app/lib/bps/pdf/roster/roster.yml")
        ).deep_symbolize_keys!
      end
    end
  end
end
