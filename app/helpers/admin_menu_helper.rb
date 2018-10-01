# frozen_string_literal: true

module AdminMenuHelper
  def admin_menu
    menus = %i[
      current files users_top review upload roster users_bottom education otw
      completions admin
    ]

    @admin_menu ||= menus.map do |menu|
      { menu => send("admin_#{menu}") }
    end.reduce({}, :merge)
  end

  def admin_current?
    admin_markdown? || admin_events? || admin_otw? || admin_event_attachments?
  end

  private

  def admin_markdown?
    current_user&.permitted?(:page) &&
      controller.action_name.in?(StaticPage.names)
  end

  def admin_events?
    current_user&.permitted?(event_type_param) &&
      controller_name.in?(%w[courses seminars events])
  end

  def admin_otw?
    current_user&.permitted?(:otw) &&
      controller_name.in?(%w[otw_trainings])
  end

  def admin_event_attachments?
    current_user&.permitted?(:event, :seminar, :course) &&
      controller_name.in?(%w[event_types locations])
  end

  def admin_current
    return unless admin_current?
    render('application/navigation/admin/current')
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
    roles = %i[users float roster excom]
    return unless current_user&.permitted?(roles)
    render('application/navigation/admin/review')
  end

  def admin_upload
    return unless current_user&.permitted?(:users, :roster)
    render('application/navigation/admin/upload')
  end

  def admin_roster
    return unless current_user&.permitted?(:users, :roster)
    render('application/navigation/admin/roster')
  end

  def admin_users_bottom
    return unless current_user&.permitted?(:users)
    render('application/navigation/admin/users_bottom')
  end

  def admin_education
    return unless current_user&.permitted?(:education)
    render('application/navigation/admin/education')
  end

  def admin_otw
    return unless current_user&.permitted?(:education)
    render('application/navigation/admin/otw')
  end

  def admin_completions
    return unless current_user&.permitted?(:education)
    render('application/navigation/admin/completions')
  end

  def admin_admin
    return unless current_user&.permitted?(:admin, strict: true)
    render('application/navigation/admin/admin')
  end
end
