# frozen_string_literal: true

# Custom string class for parsing markdown helpers
class ParsedMarkdown < String
  def initialize(string, **options)
    super(string)
    @view_context = options[:view_context]
    @files_bucket = options[:files_bucket]
    @burgee_html = options[:burgee]
    @education_menu = options[:education]
  end

  def parse
    parse_center
    parse_reg
    parse_list
    parse_email
    parse_burgee
    parse_education
    parse_image
    parse_link
    parse_static_file
    parse_fa
  end

  private

  def parse_center
    gsub!('<p>@', '<p class="center">') || self
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
    match_replace(%r{%image/(\d+)/}) do |match|
      image(match[1])
    end
  end

  def parse_link
    match_replace(%r{%file/(\d+)/([^/]*?)/}) do |match|
      file_link(match[1])
    end
  end

  def parse_static_file
    match_replace(%r{%static_file/(.*?)/([^/]*?)/}) do |match|
      static_link(match[1], title: match[2])
    end
  end

  def parse_fa
    match_replace(%r{%fa/([^/:]+):([^/]*)?/}) do |match|
      @view_context.fa_icon(match[1], css: match[2])
    end

    match_replace(%r{%fa/([^/]+)/}) do |match|
      @view_context.fa_icon(match[1])
    end
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
    link_path = @files_bucket.link("#{prefix}/#{key}")
    @view_context.link_to(link_path, target: :_blank) do
      @view_context.fa_icon('download') + link_title
    end
  end

  def image(id)
    key = "uploaded_files/#{get_uploaded_file_name(id)}"
    @view_context.image_tag(@files_bucket.link(key))
  end

  def get_uploaded_file_name(id)
    "#{id}/#{MarkdownFile.find_by(id: id)&.file_file_name}"
  end
end
