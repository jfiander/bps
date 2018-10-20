# frozen_string_literal: true

module User::Instructors
  def instructors
    @highlight = clean_params[:key].to_s.upcase
    @only = clean_params[:only] == '1' && @highlight != 'ABC'
    @instructors = User.includes(:course_completions).where('id_expr > ?', Time.now)
    @keys = %w[ABC S P AP JN N CP EM ID ME MCS MES EN SA WE] << %w[Exam SN]

    return unless @highlight.present? && @only
    @instructors = filter_instructors
  end

private

  def filter_instructors
    return sn_instructors if @highlight == 'SN'
    return me_instructors if @highlight.in?(%w[MCS MES EN])
    course_instructors
  end

  def sn_instructors
    @instructors.select { |u| u.grade == 'SN' }
  end

  def me_instructors
    @instructors.select do |u|
      u.completions.key?(@highlight) || u.completions.key?('ME')
    end
  end

  def course_instructors
    @instructors.select { |u| u.completions.key?(@highlight) }
  end
end
