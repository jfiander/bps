# frozen_string_literal: true

module BpsPdf::EducationCertificate::Seminars
  def seminars(user, **_)
    @user = user
    @completions = @user.completions
    seminar_rows
  end

  private

  def seminar_rows
    row_num = 3
    seminar_list.each_slice(6) do |row|
      row_num += 1
      completion_row(row_num) do
        (1..6).each do |column|
          seminar = row[column - 1]
          seminar_box(seminar, column) if seminar.present?
        end
      end
    end
  end

  def seminar_list
    @seminar_list ||= CodeList.new.seminars
  end

  def seminar_box(seminar, column)
    color = seminar_color(seminar)
    name = seminar_name(seminar) || seminar['name']
    date = seminar_date(seminar)

    completion_box(column, name, date, color: color)
  end

  def seminar_color(seminar)
    return 'FFFFCC' if seminar['yellow']
    return 'CCFFCC' if seminar['green']
    'FFCCCC'
  end

  def seminar_name(seminar)
    if seminar['code'].is_a?(String) || seminar['code'].nil?
      return seminar['name']
    end

    seminar_any_name(seminar) if seminar['code'].keys.first == 'any'
  end

  def seminar_date(seminar)
    if stringy_seminar_code?(seminar)
      seminar_string_date(seminar)
    elsif seminar['code'].keys.first == 'any'
      seminar_any_date(seminar)
    elsif seminar['code'].keys.first == 'all'
      seminar_all_date(seminar)
    end
  end

  def stringy_seminar_code?(seminar)
    seminar['code'].is_a?(String) || seminar['code'].nil?
  end

  def seminar_string_date(seminar)
    if seminar['name'] == 'Certified Instructor Expiration'
      @user.id_expr&.strftime('%Y-%m')
    else
      @completions[seminar['code']]
    end
  end

  def vsc_name(seminar)
    vsc = seminar['code'].values.flatten.map { |c| @completions[c] }.compact

    vsc.any?(&:present?) ? 'Certified Vessel Examiner' : 'VSC Training'
  end

  def boc_name
    return 'BOC<br>Offshore Navigator' if @completions['BOC_ON'].present?
    return 'BOC<br>Adv. Coastal Navigator' if @completions['BOC_ACN'].present?
    return 'BOC<br>Coastal Navigator' if @completions['BOC_CN'].present?
    return 'BOC<br>Inland Navigator' if @completions['BOC_IN'].present?
    'Boat Operator Certification'
  end

  def seminar_any_name(seminar)
    if seminar['name'] == 'VSC Training'
      vsc_name(seminar)
    elsif seminar['name'] == 'Boat Operator Certification'
      boc_name
    end
  end

  def seminar_any_date(seminar)
    comps = seminar['code'].values.flatten.map { |c| @completions[c] }
    comps.compact.sort_by { |c| c['date'] }.last
  end

  def seminar_all_date(seminar)
    comps = seminar['code'].values.flatten.map { |c| @completions[c] }
    comps.any?(&:nil?) ? nil : comps.sort_by { |c| c['date'] }.last
  end
end
