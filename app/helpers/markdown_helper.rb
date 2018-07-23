# frozen_string_literal: true

module MarkdownHelper
  VIEWS ||= {
    'public' => %w[home about join requirements vsc education civic history links],
    'members' => %w[members welcome user_help]
  }.freeze

  def render_markdown
    unless action_name == 'home'
      page_title(StaticPage.find_by(name: action_name).title)
    end

    render layout: 'application', inline: render_markdown_raw(name: action_name)
  end

  def render_markdown_raw(name: nil, markdown: nil)
    unless name.present? || markdown.present?
      raise ArgumentError, 'Must provide name or markdown.'
    end

    @page_markdown = markdown

    preload_markdown(name)
    generate_markdown_div
    parse_markdown_div
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

  def generate_markdown_div
    @markdown_div = +'<div class="markdown">'
    @markdown_div << redcarpet.render(@page_markdown.to_s.gsub(/(#+)/, '#\1'))
    @markdown_div << '</div>'

    @markdown_div
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
      education: education_menu(@page_markdown)
    ).parse
  end
end
