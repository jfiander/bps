# frozen_string_literal: true

module UserHelper
  INSTRUCTOR_COURSES = {
    'SN' => 'SN?',
    'CPR/AED' => 'CPR',
    'S' => 'S',
    'P' => 'P',
    'AP' => 'AP',
    'JN' => 'JN',
    'N' => 'N',
    'CP' => 'CP',
    'EM' => 'EM',
    'ID' => 'ID',
    %w[MCS ME] => 'MCS',
    %w[MES ME] => 'MES',
    %w[EN ME] => 'EN',
    'RA' => 'RA',
    'SA' => 'SA',
    'WE' => 'WE'
  }.freeze
  INSTRUCTOR_YES = FA::Icon.p('check', css: 'birmingham-blue').freeze
  INSTRUCTOR_NO = FA::Icon.p('times', css: 'gray').freeze

  def instructor_header(key, highlight, label: nil)
    class_list = class_list(key, highlight, header: true)
    default_label = key.is_a?(Array) ? key.first : key

    content_tag(:div, (label || default_label), class: class_list.join(' '))
  end

  def instructor_row(key, highlight, completions, grade: nil, cpr: nil)
    class_list = class_list(key, highlight)
    check = instructor_check(key, completions, grade: grade, cpr: cpr)

    content_tag(:div, class: class_list.join(' ')) { check ? INSTRUCTOR_YES : INSTRUCTOR_NO }
  end

  def role_flags(user)
    generate_role_flags(user.granted_roles, user.implied_roles, admin: user.permitted?(:admin))
  end

  def role_flags_from_hash(user_hash)
    generate_role_flags(
      user_hash[:granted_roles].each,
      user_hash[:implied_roles],
      admin: user_hash[:permitted_roles].include?(:admin)
    )
  end

private

  def generate_role_flags(granted, implied, admin: false)
    @role_icons ||= Role.icons

    content_tag(:div, class: 'chiclets') do
      # Granted Roles
      granted.each { |role| concat role_flag(role, :blue, :granted) }

      # Permitted Roles
      if admin
        concat role_flag(:all, :red, :permitted)
      else
        implied.each { |role| concat role_flag(role, :red, :permitted) }
      end
    end
  end

  def role_flag(role, color, type)
    title =
      if role == :all
        "#{type.to_s.titleize} for all actions"
      else
        "#{type.to_s.titleize} as #{role.to_s.titleize}"
      end

    content_tag(:div, class: color, title: title) do
      concat FA::Icon.p(@role_icons[role.to_sym], style: :duotone, fa: :fw)
      concat content_tag(:small, role.to_s.titleize)
    end
  end

  def class_list(key, highlight, header: false)
    list = %w[table-cell center]
    list << 'bold' if header
    list.tap do |l|
      case key
      when Array
        l << 'highlight' if highlight.in?(key)
      when highlight
        l << 'highlight'
      end
    end
  end

  def instructor_check(key, completions = nil, grade: nil, cpr: nil)
    case key
    when 'SN'
      return true if grade == 'SN'
    when 'CPR/AED'
      return true if cpr
    when Array
      return true if key.any? { |k| completions.include?(k) }
    else
      return true if completions.include?(key)
    end
  end
end
