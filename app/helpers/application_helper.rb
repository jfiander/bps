module ApplicationHelper
  def editor(partial, options = {})
    <<~HTML.html_safe
      <script>#{render('application/show_editor.js', page_name: partial)}</script>
      <script>#{render('application/hide_editor.js', page_name: partial)}</script>
      <noscript><style>div#editor{display:block;}</style></noscript>
      <a href='#' id='show-editor'#{auto_show(partial)}>Show Editor</a>
      <a href='#' id='hide-editor'#{auto_show(partial)}>Hide Editor</a>
      <div id='editor'#{auto_show(partial)}>#{render(partial, options)}</div>
    HTML
  end

  private

  def auto_show(partial)
    return '' unless page_name_in_auto_shows?(partial)
    " class='auto-show'"
  end

  def page_name_in_auto_shows?(partial)
    session[:auto_shows]&.include?(partial)
  end
end
