# frozen_string_literal: true

class RosterPDF < ApplicationPDF
  include RosterPDF::CoverPage
  include RosterPDF::RosterPages

  def self.create_pdf(orientation = :portrait, include_blank: false)
    @orientation = orientation
    page_width = 792 / (@orientation == :landscape ? 2 : 1)
    RosterPDF.generate('tmp/run/Roster.pdf', page_layout: @orientation, page_size: [612, page_width]) do
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

  private

  def load_logo
    logo = BpsS3.new(:static).download('logos/ABC.long.birmingham.1000.png')
    File.open('tmp/run/ABC-B.png', 'w+') { |f| f.write(logo) }
  end

  def load_burgee
    burgee = BpsS3.new(:static).download('flags/Birmingham/Birmingham.png')
    File.open('tmp/run/Burgee.png', 'w+') { |f| f.write(burgee) }
  end

  def config
    @config ||= YAML.safe_load(
      File.read("#{Rails.root}/app/lib/roster_pdf/roster.yml")
    ).deep_symbolize_keys!
  end
end
