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
    unless name.present? || markdown.present?
      raise ArgumentError, 'Must provide name or markdown.'
    end

    @page_markdown = markdown

    preload_markdown(name)
    default_markdown(@page_markdown)
    generate_markdown_div
    parse_markdown_div
  end

  private

  def preload_markdown(name)
    @page_markdown ||= StaticPage.find_by(name: name)&.markdown
    @page_markdown
  end

  def default_markdown(markdown)
    @burgee_html = if markdown&.match?(/%burgee/)
                     center_html('burgee') do
                       USPSFlags::Burgees.new do |b|
                         b.squadron = :birmingham
                         b.outfile = ''
                       end.svg
                     end
                   else
                     ''
                   end

    @education_menu = if markdown&.match?(/%education/)
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
    @markdown_div
      .gsub('<p>@', '<p class="center">')
      .gsub('&reg;', '<sup>&reg;</sup>')
      .gsub('<ul>', '<ul class="md">')
      .gsub(/href='(.+@.+\..+)'/) { "href='mailto:#{$1}'" }
      .gsub(%r{<p>%burgee</p>}, @burgee_html)
      .gsub(%r{<p>%education</p>}, @education_menu)
      .gsub(%r{(.*?)%static_file/(.*?)/(.*?)/(.*?)$}) { $1 + static_link($2, title: $3) + $4 }
      .gsub(%r{(.*?)%file/(\d+)/(.*?)/(.*?)$}) { $1 + file_link($2, title: $3) + $4 }
      .gsub(%r{(.*?)%image/(\d+)/(.*?)$}) { $1 + image($2) + $3 }
      .gsub(%r{(.*?)%fa/(.*?):(.*?)/(.*?)$}) { $1 + view_context.fa_icon($2, css: $3) + $4 }
      .gsub(%r{(.*?)%fa/(.*?)/(.*?)$}) { $1 + view_context.fa_icon($2) + $3 }
  end

  def center_html(classes = '')
    "<div class='center #{classes}'>" + yield + '</div>'
  end

  def static_link(id, title: nil)
    markdown_link(prefix: 'general', id: id, title: title)
  end

  def file_link(id, title: nil)
    markdown_link(prefix: 'uploaded_files', id: id, title: title)
  end

  def markdown_link(prefix:, id:, title: nil)
    key = get_uploaded_file_name(id)
    link_title = title || key
    link_path = files_bucket.link("#{prefix}/#{key}")
    view_context.link_to(link_path, target: :_blank) do
      view_context.fa_icon('download') + link_title
    end
  end

  def image(id)
    key = "uploaded_files/#{get_uploaded_file_name(id)}"
    view_context.image_tag(files_bucket.link(key))
  end

  def get_uploaded_file_name(id)
    "#{id}/#{MarkdownFile.find_by(id: id)&.file_file_name}"
  end
end
