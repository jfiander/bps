class TargetBlankRenderer < Redcarpet::Render::HTML
  def link(link, title, alt_text)
    if link.match(/^https?:\/\/#{ENV["DOMAIN"]}\/.*/) || link.match(/^\//)
      "<a href='#{link}'>#{alt_text}</a>"
    else
      "<a target='_blank' href='#{link}'>#{alt_text}</a>"
    end
  end

  def autolink(link, link_type)
    link(link, nil, link)
  end
end
