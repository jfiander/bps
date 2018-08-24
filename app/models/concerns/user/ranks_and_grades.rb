# frozen_string_literal: true

module User::RanksAndGrades
  def valid_ranks
    %w[
      P/Lt/C P/C 1/Lt Lt/C Cdr Lt F/Lt
      P/D/Lt/C P/D/C D/1/Lt D/Lt/C D/C D/Lt D/Aide D/F/Lt
      P/Stf/C P/R/C P/V/C P/C/C N/Aide N/F/Lt P/N/F/Lt Stf/C R/C V/C C/C
    ]
  end

  def valid_grades
    %w[S P AP JN N SN]
  end

  def auto_rank(html: true)
    highest_rank(*ranks(html: html))
  end

  def html_rank
    # html_safe: No user content
    auto_rank(html: true)&.html_safe
  end

  def ranks(html: true)
    committee_rank = 'Lt' if committee?
    committee_rank = 'F/Lt' if 'Flag Lieutenant'.in? cached_committees.map(&:name)

    [bridge_rank(html), override_rank, committee_rank].reject(&:blank?)
  end

  def formatted_grade
    grade.present? ? ", #{grade}" : ''
  end

  def long_grade
    {
      'S' => 'Seaman',
      'P' => 'Pilot',
      'AP' => 'Advanced Pilot',
      'JN' => 'Junior Navigator',
      'N' => 'Navigator',
      'SN' => 'Senior Navigator'
    }[grade]
  end

  private

  def override_rank
    return '' if rank_override == 'none'
    return rank_override if rank_override.present?
    rank
  end

  def bridge_rank(html = true)
    case cached_bridge_office&.office
    when 'commander'
      'Cdr'
    when *ltc_offices
      'Lt/C'
    when *first_lt_offices
      html ? '1<sup>st</sup>/Lt' : '1st/Lt'
    end
  end

  def ltc_offices
    %w[executive administrative educational secretary treasurer]
  end

  def first_lt_offices
    %w[asst_educational asst_secretary]
  end

  def committee?
    cached_standing_committees.present? || cached_committees.present?
  end

  def valid_rank
    return true if rank.nil?
    return true if rank.in? valid_ranks
    errors.add(:rank, 'must be nil or in valid_ranks')
  end

  def valid_grade
    return true if grade.nil?
    self.grade = grade.to_s.upcase
    return true if grade.in? valid_grades
    errors.add(:grade, 'must be nil or in valid_grades')
  end

  def highest_rank(*ranks)
    rank_priority = YAML.safe_load("#{Rails.root}/lib/rank_priorities.yml")

    rp = ranks.map do |r|
      { r => (rank_priority[r] || 100) }
    end

    rp.reduce({}, :merge).min_by { |_, p| p }&.first
  end
end
