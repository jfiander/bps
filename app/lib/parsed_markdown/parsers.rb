# frozen_string_literal: true

module ParsedMarkdown::Parsers
private

  def parse_center
    gsub!(/<p>(\+?)@/, '<p class="center">\1') || self
  end

  def parse_big
    gsub!(/<p class="center">\+/, '<p class="center bigger bold">') || self
    gsub!('<p>+', '<p class="bigger bold">') || self
  end

  def parse_reg
    gsub!('&reg;', '<sup>&reg;</sup>') || self
  end

  def parse_list
    gsub!('<ul>', '<ul class="md">') || self
  end

  def parse_email
    gsub!(/href='(.+@.+\.\w+)'.*?/, 'href="mailto:\1"') || self
  end

  def parse_burgee
    gsub!(%r{<p>%burgee</p>}, center_html('burgee') { @burgee_html }) || self
  end

  def parse_education
    gsub!(%r{<p>%education</p>}, @education_menu) || self
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
    return self unless match?(%r{%fal/[^/]*/})

    while match?(%r{%fal/[^/]*/})
      original = match(%r{%fal/[^/]*/})[0]
      icons = scan_layer_icons(original)
      gsub!(original, FA::Layer.p(icons))
    end
  end

  def scan_layer_icons(original)
    original.scan(%r{([^/:;]+)(?::([^/:;]+))?}).map do |(icon, css)|
      { name: icon, options: { css: css } } unless icon == '%fal'
    end.compact
  end

  def parse_fa
    match_replace(%r{%fa/([^/:]+):([^/]*)/}) { |match| FA::Icon.p(match[1], css: match[2]) }
    match_replace(%r{%fa/([^/]+)/}) { |match| FA::Icon.p(match[1]) }
  end
end
