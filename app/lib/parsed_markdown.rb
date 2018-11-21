# frozen_string_literal: true

# Custom string class for parsing markdown helpers
class ParsedMarkdown < String
  include ParsedMarkdown::Parsers

  def initialize(string, **options)
    super(string)
    @view_context = options[:view_context]
    @files_bucket = options[:files_bucket]
    @burgee_html = options[:burgee]
    @education_menu = options[:education]
  end

  def parse
    %i[center big reg list email burgee education image link fal fa].each do |parser|
      send("parse_#{parser}")
    end
    self
  end

private

  def center_html(classes = '')
    "<div class='center #{classes}'>" + yield + '</div>'
  end

  def static_link(id, title: nil)
    markdown_link(prefix: 'general', id: id, title: title)
  end

  def file_link(id, title: nil)
    markdown_link(prefix: 'uploaded/markdown_files', id: id, title: title)
  end

  def markdown_link(prefix:, id:, title: nil)
    key = get_uploaded_file_name(id)
    link_title = title || key
    link_path = @files_bucket.link("#{prefix}/#{key}")
    @view_context.link_to(link_path, target: :_blank) { FA::Icon.p('download') + link_title }
  end

  def image(id)
    key = "uploaded/markdown_files/#{get_uploaded_file_name(id)}"
    @view_context.image_tag(@files_bucket.link(key))
  end

  def get_uploaded_file_name(id)
    "#{id}/#{MarkdownFile.find_by(id: id)&.file_file_name}"
  end
end
