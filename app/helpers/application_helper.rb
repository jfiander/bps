module ApplicationHelper
  def editor(partial, options = {})
    link = "<a href='#' id='show-editor'#{auto_show}>Show Editor</a>"
    top = "<div id='editor'#{auto_show}>"
    bottom = '</div>'
    link.html_safe +
      top.html_safe +
      render(partial, options) +
      bottom.html_safe
  end

  private

  def auto_show
    return '' unless true # session says link was clicked
    " class='auto-show'"
  end
end
