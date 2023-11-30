# frozen_string_literal: true

module ApplicationHelper
  # rubocop:disable Rails/OutputSafety
  # html_safe: No user content
  def formatted_error_flash(error)
    if error.present? && error.is_a?(String)
      error
    elsif error.present? && error&.count == 1
      error.first
    elsif error.present?
      errors = safe_join(error&.map { |e| content_tag(:li, e) })
      content_tag(:ul, errors).html_safe
    end
  end
  # rubocop:enable Rails/OutputSafety

  def get_user(id)
    user = @users.find_all { |u| u.id == id }.first
    return user.bridge_hash if user.present?

    { full_name: 'TBD', simple_name: 'TBD', photo: User.no_photo }
  end

  def editor(partial = 'editor', options = {})
    opts = { name: 'Editor' }.merge(options)
    content_for(:head) { render('application/editor/head', partial: partial) }
    render('application/editor/buttons', partial: partial, options: opts)
  end

  def auto_show(partial)
    session[:auto_shows]&.include?(partial) ? 'auto-show' : ''
  end

  def admin_header(header_text)
    admin_icon = FA::Icon.p('shield-check', style: :duotone)
    content_tag(:div, class: 'admin-header') do
      concat content_tag(:div, admin_icon, class: 'admin-header-icon')
      concat content_tag(:div, header_text)
      concat content_tag(:div, admin_icon, class: 'admin-header-icon')
    end
  end

  def sanitize(text)
    ActionController::Base.helpers.sanitize text
  end

  def switch_box(f, field, color, description, **options)
    content_tag(:label, class: 'switch') do
      concat(switch_box_field(f, field, options[:value], id: options[:id]))
      concat(switch_box_span(color, description))
    end
  end

private

  def switch_box_field(f, field, value = nil, id: nil)
    if f.nil?
      check_box_tag(field, '1', value, class: 'slider round', id: id)
    else
      f.check_box(field, class: 'slider round')
    end
  end

  def switch_box_span(color, description)
    content_tag(:span, class: "slider round #{color}") do
      content_tag(:div, '', class: "description #{description}")
    end
  end
end
