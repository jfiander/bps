# frozen_string_literal: true

module ApplicationHelper
  def formatted_error_flash(error)
    # html_safe: No user content
    if error.present? && error&.is_a?(String)
      error
    elsif error.present? && error&.count == 1
      error.first
    elsif error.present?
      errors = safe_join(error&.map { |e| content_tag(:li, e) })
      content_tag(:ul, errors).html_safe
    end
  end

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
    # html_safe: No user content
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

  def auto_show(partial)
    session[:auto_shows]&.include?(partial) ? 'auto-show' : ''
  end

  def admin_header(header_text)
    admin_icon = FA::Icon.p('shield-check', style: :regular)
    admin_icon + header_text + admin_icon
  end

  def main_menu
    @main_menu ||= content_tag(:ul, render('application/navigation/links'))
  end

  def admin_menu
    @admin_menu ||= {
      current: admin_current,
      files: admin_files,
      users_top: admin_users_top,
      review: admin_review,
      upload: admin_upload,
      users_bottom: admin_users_bottom,
      admin: admin_admin
    }
  end

  private

  def admin_current
    return unless admin_current?

    render('application/navigation/admin/current')
  end

  def admin_current?
    (current_user&.permitted?(:page) &&
      controller.action_name.in?(StaticPage.names)) ||
      current_user&.permitted?(event_type_param) ||
      (
        current_user&.permitted?(:event, :seminar, :course) &&
        controller_name.in?(%w[event_types locations])
      )
  end

  def admin_files
    return unless current_user&.permitted?(:page)

    render('application/navigation/admin/files')
  end

  def admin_users_top
    return unless current_user&.permitted?(:users)

    render('application/navigation/admin/users_top')
  end

  def admin_review
    return unless
      current_user&.permitted?(:users, :float, :roster) || current_user&.excom?

    render('application/navigation/admin/review')
  end

  def admin_upload
    return unless current_user&.permitted?(:users, :roster)

    render('application/navigation/admin/upload')
  end

  def admin_users_bottom
    return unless current_user&.permitted?(:users)

    render('application/navigation/admin/users_bottom')
  end

  def admin_admin
    return unless current_user&.permitted?(:admin, strict: true)

    render('application/navigation/admin/admin')
  end

  def sanitize(text)
    ActionController::Base.helpers.sanitize text
  end
end
