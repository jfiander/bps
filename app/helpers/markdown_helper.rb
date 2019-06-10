# frozen_string_literal: true

module MarkdownHelper
  VIEWS ||= {
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

  def next_meeting(markdown)
    markdown&.match?(/%meeting/) ? view_context.render('members/next_meeting') : ''
  end

  def next_excom_meeting(markdown)
    markdown&.match?(/%excom/) ? view_context.render('members/next_excom') : ''
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
      files_bucket: files_bucket,
      burgee: burgee_html(@page_markdown),
      education: education_menu(@page_markdown),
      next_meeting: next_meeting(@page_markdown),
      next_excom: next_excom_meeting(@page_markdown)
    ).parse
  end

  def parse_external_links
    @ext ||= FA::Icon.p('external-link')

    @markdown_div = @markdown_div.gsub(
      %r{(<a.*?href=['"]https?://.*?['"].*?>.*?)</a>},
      '\1' + "<sup>#{@ext}</sup></a>"
    )
  end
end
