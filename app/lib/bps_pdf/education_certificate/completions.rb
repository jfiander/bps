# frozen_string_literal: true

module BpsPdf::EducationCertificate::Completions
  def completions(user, membership_date: nil, last_mm: nil)
    top_row(user, membership_date, last_mm)
    course_completions = user.completions
    ag_row(user, course_completions)
    elec_row(course_completions)
  end

private

  def top_row(user, membership_date = nil, last_mm = nil)
    color = 'FFFFCC'
    completion_row(1) do
      completion_box(1, 'Membership Date', membership_date, color: color)
      completion_box(2, 'Dues Periods', user.total_years, color: color)
      completion_box(3, 'Merit Marks', user.mm, color: color)
      completion_box(4, 'Last MM', last_mm, color: color)
      completion_box(5, *member_level(user), color: color)
      completion_box(6, 'Governing Board Member Emeritus', gb_emeritus(user), color: color)
    end
  end

  def ag_row(user, course_completions)
    color = 'CCFFFF'
    completion_row(2) do
      completion_box(1, 'Seamanship', course_completions['S'], color: color)
      completion_box(2, 'Piloting', course_completions['P'], color: color)
      completion_box(3, 'Advanced Piloting', course_completions['AP'], color: color)
      completion_box(4, 'Junior Navigation', course_completions['JN'], color: color)
      completion_box(5, 'Navigation', course_completions['N'], color: color)
      completion_box(6, *educ_award(user), color: color)
    end
  end

  def elec_row(course_completions)
    color = 'CCFFFF'
    completion_row(3) do
      completion_box(1, 'Cruise Planning', course_completions['CP'], color: color)
      completion_box(2, 'Engine Maintenance', course_completions['EM'], color: color)
      completion_box(3, 'Instructor Development', course_completions['ID'], color: color)
      me_name, me_date = me_completion(course_completions) || ['MCS, MES, EN', nil]
      completion_box(4, "Marine Electronics #{me_name_sized(me_name)}", me_date, color: color)
      completion_box(5, 'Sail', course_completions['SA'], color: color)
      completion_box(6, 'Weather', course_completions['WE'], color: color)
    end
  end

  def me_name_sized(me_name)
    "<font size='6'>#{me_name}</font>"
  end

  def member_level(user)
    if user.life?
      ['Life Member', user.life.strftime('%Y')]
    elsif user.senior?
      ['Senior Member', user.senior.strftime('%Y')]
    else
      ['Senior or Life Member', nil]
    end
  end

  def gb_emeritus(user)
    return unless user.mm.present?

    'Yes' if user.mm > 50
  end

  def educ_award(user)
    if user.ed_ach.present?
      ['Educational Achievement', user.ed_ach.strftime('%Y-%m')]
    elsif user.ed_pro.present?
      ['Educational Proficiency', user.ed_pro.strftime('%Y-%m')]
    else
      ['Educational Achievement or Proficiency', nil]
    end
  end

  def me_completion(course_completions)
    if course_completions['ME'].present?
      ['ME', course_completions['ME']]
    elsif old_me_modules?(course_completions)
      old_me_modules(course_completions)
    elsif new_me_courses?(course_completions)
      modern_me_courses(course_completions)
    end
  end

  def old_me_modules?(course_completions)
    course_completions['ME101'].present? &&
      course_completions['ME102'].present? &&
      course_completions['ME103'].present?
  end

  def new_me_courses?(course_completions)
    course_completions['CS_000C'].present? ||
      course_completions['ES_000C'].present? ||
      course_completions['NS_000C'].present?
  end

  def old_me_modules(course_completions)
    [
      'ME',
      [
        course_completions['ME101'],
        course_completions['ME102'],
        course_completions['ME103']
      ].sort_by { |c| c['date'] }.last
    ]
  end

  def modern_me_courses(course_completions)
    [
      modern_me_names(course_completions),
      [
        course_completions['CS_000C'],
        course_completions['ES_000C'],
        course_completions['NS_000C']
      ].compact.sort_by { |c| c['date'] }.first
    ]
  end

  def modern_me_names(course_completions)
    [
      ('MCS' if course_completions['CS_000C'].present?),
      ('MES' if course_completions['ES_000C'].present?),
      ('EN' if course_completions['NS_000C'].present?)
    ].compact.join(', ')
  end
end
