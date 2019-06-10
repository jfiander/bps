# frozen_string_literal: true

module Application
  module Meta
    # This module defines no public methods.
    def _; end

  private

    def page_title(title = nil)
      title = "#{title} | " if title.present?
      @title = "#{title}America's Boating Club – Birmingham Squadron"
    end

    def meta_tags
      page_title
      site_description
      site_keywords
    end

    def site_description
      @site_description ||= <<~DESCRIPTION
        Are you a power or sail boat enthusiast in the Birmingham, MI area?
        Do you know the names of the knots you use?
        Join the Birmingham chapter of the United States Power Squadrons®.
      DESCRIPTION
    end

    def site_keywords
      @site_keywords ||= <<~KEYWORDS
        America's Boating Club®, America's Boating Club, birminghampowersquadron.org, Power Squadron,
        bpsd9.org, Michigan, Boating Safety, D9, District 9, fun boating, boating, Birmingham, boater,
        water, recreation, recreational, safety, vessels, education, boating classes, join, weather,
        sail, sailing, powerboats, sailboats, marine, maritime, nautical, navigation, courses,
        classes, Birmingham Power Squadron, Power Squadron vsc, Power Squadron Vessel Exams, USPS,
        Power Squadron, United States Power Squadrons, USPS, Safe Boating, VSC, Vessel Exams,
        Vessel Safety Checks, vessel safety
      KEYWORDS
    end
  end
end
