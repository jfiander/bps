# frozen_string_literal: true

class User
  module Instructors
    def instructors
      load_instructor_data
      return unless @highlight.present? && @only

      @instructors = filter_instructors
    end

  private

    def load_instructor_data
      @highlight = clean_params[:key].to_s.upcase
      @only = clean_params[:only] == '1'
      @instructors = User.unlocked.alphabetized.includes(:course_completions).where(
        'id_expr > ? OR (cpr_aed_expires_at IS NOT NULL AND cpr_aed_expires_at > ?)',
        Time.zone.now, Time.zone.now
      )
      @keys = %w[ABC CPR/AED S P AP JN N CP EM ID ME MCS MES EN RA SA WE] << %w[Exam SN]
    end

    def filter_instructors
      return abc_instructors if @highlight == 'ABC'
      return sn_instructors if @highlight == 'SN'
      return cpr_instructors if @highlight == 'CPR/AED'
      return me_instructors if @highlight.in?(%w[MCS MES EN])

      course_instructors
    end

    def abc_instructors
      @instructors.select { |u| u.id_expr.present? && u.id_expr > Time.zone.now }
    end

    def sn_instructors
      @instructors.select { |u| u.grade == 'SN' }
    end

    def cpr_instructors
      @instructors.select(&:cpr_aed?)
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
end
