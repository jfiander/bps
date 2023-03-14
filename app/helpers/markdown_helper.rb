# frozen_string_literal: true

module MarkdownHelper
  VIEWS = {
    'public' => %w[home about join requirements vsc education civic history links],
    'members' => %w[members welcome user_help]
  }.freeze

  def render_markdown
    page_title(StaticPage.find_by(name: action_name).title) unless action_name == 'home'

    render layout: 'application', inline: render_markdown_raw(name: action_name)
  end

  def render_markdown_raw(name: nil, markdown: nil)
    raise ArgumentError, 'Must provide name or markdown.' unless name.present? || markdown.present?

    @page_markdown = markdown

    preload_markdown(name)
    generate_markdown_div
    parse_markdown_div
    parse_external_links if ENV['MARK_EXTERNAL_LINKS'] == 'enabled'
    remove_empty_table_headers
    @markdown_div
  end

  def simple_markdown(markdown)
    sanitize(redcarpet.render(markdown.to_s))
  end

private

  def preload_markdown(name)
    @page_markdown ||= StaticPage.find_by(name: name)&.markdown
    @page_markdown
  end

  def burgee_html(markdown)
    if markdown&.match?(/%burgee/)
      USPSFlags::Burgees.new do |b|
        b.squadron = :birmingham
        b.outfile = ''
      end.svg
    else
      ''
    end
  end

  def education_menu(markdown)
    if markdown&.match?(/%education/)
      view_context.render(
        'application/navigation/education',
        active: { courses: false, seminars: false }
      )
    else
      ''
    end
  end

  # Pattern description
  #   pattern = /^%#{key}(((?:\r?\n)(.*?))*?)(?:(?:\r?\n){2}|\z)/
  #
  #   ^%#{key}              Beginning with primary key
  #   ((?:\r?\n)(.*?))*?    Optionally followed by any number of immediate newline with more text
  #   (?:(?:\r?\n){2}|\z)   Ending with either two newlines, or the end of the entire page contents
  #
  # rubocop:disable Rails/OutputSafety
  # html_safe: Text is sanitized before storage
  def next_scheduled(key, markdown)
    contents = '(?:\r?\n)(.*?)'
    tail = '(?:(?:\r?\n){2}|\z)'
    pattern = /^%#{key}((#{contents})*?)#{tail}/
    return '' unless markdown&.match?(pattern)

    markdown.match(pattern) do |m|
      details = redcarpet.render(m[1]).html_safe if m[1].present?
      view_context.render("members/next_#{key}", details: details)
    end
  end
  # rubocop:enable Rails/OutputSafety

  def activity_feed(markdown)
    @activity_feed = Event.fetch_activity_feed
    markdown&.match?(/%activity/) ? view_context.render('public/activity') : ''
  end

  def generate_markdown_div
    @markdown_div = +'<div class="markdown">'
    @markdown_div << redcarpet.render(@page_markdown.to_s)
    @markdown_div << '</div>'

    sanitize(@markdown_div)
  end

  def redcarpet
    Redcarpet::Markdown.new(
      TargetBlankRenderer,
      autolink: true,
      images: true,
      tables: true,
      no_intra_emphasis: true,
      strikethrough: true,
      superscript: true,
      underline: true
    )
  end

  def parse_markdown_div
    @markdown_div = ParsedMarkdown.new(
      @markdown_div,
      view_context: (view_context unless Rails.env.test?),
      files_bucket: BPS::S3.new(:files),
      static_bucket: BPS::S3.new(:static),
      burgee: burgee_html(@page_markdown),
      education: education_menu(@page_markdown),
      next_meeting: next_scheduled(:meeting, @page_markdown),
      next_excom: next_scheduled(:excom, @page_markdown),
      activity: activity_feed(@page_markdown)
    ).parse
  end

  def parse_external_links
    @ext ||= FA::Icon.p('external-link')

    @markdown_div = @markdown_div.gsub(
      %r{(<a.*?href=['"]https?://.*?['"].*?>.*?)(</button>)?</a>},
      '\1' \
      "<sup>#{@ext}</sup>" \
      '\2</a>'
    )
  end

  def remove_empty_table_headers
    @markdown_div = @markdown_div.gsub(%r{<thead>\n<tr>\n(<th></th>\n)+</tr>\n</thead>}, '')
  end
end
