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

private

  def class_list(key, highlight, header: false)
    list = %w[table-cell center]
    list << 'table-header' if header
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
