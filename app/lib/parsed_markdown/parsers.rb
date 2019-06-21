# frozen_string_literal: true

class ParsedMarkdown
  module Parsers
    # This module defines no public methods.
    def _; end

  private

    def gsubs!(pattern, replacement)
      gsub!(pattern, replacement)
      self
    end

    def parse_center
      gsubs!(/<p>(\+?)@/, '<p class="center">\1')
    end

    def parse_big
      gsubs!(/<p class="center">\+/, '<p class="center bigger bold">')
      gsubs!('<p>+', '<p class="bigger bold">')
    end

    def parse_reg
      gsubs!('&reg;', '<sup>&reg;</sup>')
    end

    def parse_list
      gsubs!('<ul>', '<ul class="md">')
    end

    def parse_email
      gsubs!(/href='(.+@.+\.\w+.*?)'.*?/, 'href="mailto:\1"')
    end

    def parse_burgee
      gsubs!(%r{<p>%burgee</p>}, center_html('burgee') { @burgee_html })
    end

    def parse_education
      gsubs!(%r{<p>%education</p>}, @education_menu)
    end

    def parse_meeting
      gsubs!(%r{<p>%meeting</p>}, @next_meeting)
    end

    def parse_excom
      gsubs!(%r{<p>%excom</p>}, @next_excom)
    end

    def match_replace(pattern)
      match(pattern) { |m| gsub!(m[0], yield(m)) } while match?(pattern)
      self
    end

    def parse_image
      match_replace(%r{%image/(\d+)/}) { |match| image(match[1]) }
    end

    def parse_link
      match_replace(%r{%file/(\d+)/([^/]*?)/}) { |match| file_link(match[1], title: match[2]) }
    end

    def parse_fal
      layer_regexp = %r{%fal/[^/]*/}
      return self unless match?(layer_regexp)

      while match?(layer_regexp)
        original = match(layer_regexp)[0]
        icons = scan_layer_icons(original)
        gsubs!(original, FA::Layer.p(icons))
      end
    end

    def scan_layer_icons(original)
      original.scan(%r{([^/:;]+)(?::([^/:;]+))?}).map do |(icon, css)|
        { name: icon, options: { css: css } } unless icon == '%fal'
      end.compact
    end

    def parse_fa
      parse_fa_with_class
      parse_fa_bare
    end

    def parse_fa_with_class
      match_replace(%r{%fa/([^/:]+):([^/]*)/}) { |match| FA::Icon.p(match[1], css: match[2]) }
    end

    def parse_fa_bare
      match_replace(%r{%fa/([^/]+)/}) { |match| FA::Icon.p(match[1]) }
    end
  end
end
