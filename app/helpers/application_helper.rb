module ApplicationHelper
  def get_user(id)
    user = @users.find_all { |u| u.id == id }.first

    return user.bridge_hash if user.present?

    {
      full_name: 'TBD',
      simple_name: 'TBD',
      photo: User.no_photo
    }
  end

  def editor(partial, options = {})
    content_for :head do
      <<~HTML.html_safe
        <script>#{render('application/show_editor.js', page_name: partial)}</script>
        <script>#{render('application/hide_editor.js', page_name: partial)}</script>
        <noscript><style>div#editor{display:block;}a#show-editor,a#hide-editor{display:none;}</style></noscript>
      HTML
    end

    <<~HTML.html_safe
      <div id='editor-buttons'>
        <a href='#' id='show-editor' class='medium #{auto_show(partial)}'>Show Editor</a>
        <a href='#' id='hide-editor' class='medium #{auto_show(partial)}'>Hide Editor</a>
      </div>
      <div id='editor' class='#{auto_show(partial)}'>#{render(partial, options)}</div>
    HTML
  end

  private

  def auto_show(partial)
    return '' unless page_name_in_auto_shows?(partial)
    'auto-show'
  end

  def page_name_in_auto_shows?(partial)
    session[:auto_shows]&.include?(partial)
  end

  def page_title(title = nil)
    title = "#{title} | " if title.present?
    @title = "#{title}America's Boating Club – Birmingham Squadron"
  end
end
