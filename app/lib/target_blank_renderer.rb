# frozen_string_literal: true

class TargetBlankRenderer < Redcarpet::Render::HTML
  def link(link, title, alt_text)
    if link&.match(%r{^https?://#{ENV["DOMAIN"]}/.*}) || link&.match(%r{^/})
      "<a href='#{link}' title='#{title}'>#{alt_text}</a>"
    else
      "<a target='_blank' href='#{link}' title='#{title}'>#{alt_text}</a>"
    end
  end

  def autolink(link, _link_type)
    link(link, nil, link)
  end
end
