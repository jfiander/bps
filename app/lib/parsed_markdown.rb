# frozen_string_literal: true

# Custom string class for parsing markdown helpers
class ParsedMarkdown < String
  PARSERS ||= %i[
    comments center big reg list email
    burgee education meeting excom classed activity
    image link button fam fa signal_flag
  ].freeze

  include ParsedMarkdown::Parsers

  def initialize(string, **options)
    super(string)
    @view_context = options[:view_context]
    @files_bucket = options[:files_bucket]
    @static_bucket = options[:static_bucket]
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
    markdown_link_or_button(prefix: 'general', id: id, title: title, mode: :link)
  end

  def file_link(id, title: nil)
    markdown_link_or_button(prefix: 'uploaded/markdown_files', id: id, title: title, mode: :link)
  end

  def file_button(id, title: nil)
    markdown_link_or_button(prefix: 'uploaded/markdown_files', id: id, title: title, mode: :button)
  end

  def signal_flag(text, css: nil)
    @view_context.content_tag(:div, class: ['signals', css].compact.join(' '), title: text) do
      text.scan(/[A-Za-z0-9\s]/).map(&:downcase).split(' ').map do |word|
        @view_context.content_tag(:div, class: 'word') do
          word.map do |letter|
            @view_context.image_tag(
              @static_bucket.link("signals/SVG/short/#{letter}.svg"), alt: letter
            ).html_safe
          end.join.html_safe
        end
      end.join.html_safe
    end
  end

  def markdown_link_or_button(prefix:, id:, title: nil, mode: :link)
    raise "Invalid mode: #{mode}" unless mode.in?(%i[link button])

    key = get_uploaded_file_name(id)
    link_title = title || key
    link_path = @files_bucket.link("#{prefix}/#{key}")
    @view_context.link_to(link_path, target: :_blank) do
      if mode == :button
        @view_context.content_tag(:button, class: 'blue-button') do
          FA::Icon.p('download', style: :duotone) + link_title
        end
      else
        FA::Icon.p('download', style: :duotone) + link_title
      end
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
