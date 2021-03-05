# frozen_string_literal: true

# Custom string class for parsing markdown helpers
class ParsedMarkdown < String
  PARSERS ||= %i[
    comments center big reg list email
    burgee education meeting excom classed activity
    image link fam fa
  ].freeze

  include ParsedMarkdown::Parsers

  def initialize(string, **options)
    super(string)
    @view_context = options[:view_context]
    @files_bucket = options[:files_bucket]
    @burgee_html = options[:burgee]
    @education_menu = options[:education]
    @next_meeting = options[:next_meeting]
    @next_excom = options[:next_excom]
    @activity = options[:activity]
  end

  def parse
    PARSERS.each { |parser| send("parse_#{parser}") }
    self
  end

private

  def center_html(classes = '')
    "<div class='center #{classes}'>#{yield}</div>"
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
    @view_context.link_to(link_path, target: :_blank) do
      FA::Icon.p('download', style: :duotone) + link_title
    end
  end

  def image(id)
    key = "uploaded/markdown_files/#{get_uploaded_file_name(id)}"
    @view_context.image_tag(@files_bucket.link(key))
  end

  def get_uploaded_file_name(id)
    "#{id}/#{MarkdownFile.find_by(id: id)&.file_file_name}"
  end
end
