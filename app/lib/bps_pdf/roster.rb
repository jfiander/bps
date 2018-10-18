# frozen_string_literal: true

class BpsPdf::Roster < BpsPdf::Base
  include  BpsPdf::Roster::Shared
  include  BpsPdf::Roster::Simple::CoverPage
  include  BpsPdf::Roster::Simple::RosterPages

  def self.create_pdf(orientation = :portrait, include_blank: false)
    @orientation = orientation
    page_width = 792 / (@orientation == :landscape ? 2 : 1)
     BpsPdf::Roster.generate('tmp/run/Roster.pdf', page_layout: @orientation, page_size: [612, page_width]) do
      specify_font
      configure_colors

      cover_page(orientation, include_blank: include_blank)
      roster_pages(User.unlocked.alphabetized, orientation)
    end

    File.open('tmp/run/Roster.pdf', 'r+')
  end

  def self.portrait(_ignored = nil)
    create_pdf(:portrait)
  end

  def self.landscape(include_blank: false)
    create_pdf(:landscape, include_blank: include_blank)
  end

  def self.detailed(*_ignored)
     BpsPdf::Roster::Detailed.create_pdf
  end

  private

  def config
    @config ||= YAML.safe_load(
      File.read("#{Rails.root}/app/lib/bps_pdf/roster/roster.yml")
    ).deep_symbolize_keys!
  end
end
