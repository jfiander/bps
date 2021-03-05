# frozen_string_literal: true

class ParsedMarkdown
  module Parsers
    PARAGRAPH_CONTENTS = '((\n|.)*?)?'

    # This module defines no public methods.
    def _; end

  private

    def gsubs!(pattern, replacement)
      gsub!(pattern, replacement)
      self
    end

    # Only allows one subsitution per page
    def subs!(pattern, replacement)
      sub!(pattern, replacement)
      self
    end

    def parse_comments
      gsubs!(%r{<p>//#{PARAGRAPH_CONTENTS}</p>}, '')
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

    # Only allows one subsitution per page
    def parse_meeting
      subs!(%r{<p>%meeting#{PARAGRAPH_CONTENTS}</p>}, @next_meeting)
    end

    # Only allows one subsitution per page
    def parse_excom
      subs!(%r{<p>%excom#{PARAGRAPH_CONTENTS}</p>}, @next_excom)
    end

    def parse_classed
      gsubs!(%r{<p>%%(.*?)\n#{PARAGRAPH_CONTENTS}</p>}, '<p class="\1">\2</p>')
    end

    def parse_activity
      gsubs!(%r{<p>%activity</p>}, '')
      self << @activity if activity_feed?
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

    # Custom key for "FA-Multiple" - layered icons
    def parse_fam
      layer_regexp = %r{%fam/[^/]*/}
      return self unless match?(layer_regexp)

      while match?(layer_regexp)
        original = match(layer_regexp)[0]
        icons = scan_layer_icons(original)
        gsubs!(original, FA::Layer.p(icons))
      end
    end

    def scan_layer_icons(original)
      original.scan(%r{([^/:;]+)(?::([^/:;]+))?}).map do |(icon, css)|
        { name: icon, options: { css: css } } unless icon == '%fam'
      end.compact
    end

    def parse_fa
      parse_fa_with_class
      parse_fa_bare
    end

    def parse_fa_with_class
      match_replace(%r{%fa([srltdbk])?/([^/:]+):([^/]*)/}) do |match|
        FA::Icon.p(match[2], css: match[3], style: fa_style(match[1]))
      end
    end

    def parse_fa_bare
      match_replace(%r{%fa([srltdbk])?/([^/]+)/}) do |match|
        FA::Icon.p(match[2], style: fa_style(match[1]))
      end
    end

    def fa_style(match)
      return :solid unless match

      FA::Base::STYLES.invert[match]
    end
  end

  def activity_feed?
    Event.activity_feed.any?
  end
end
