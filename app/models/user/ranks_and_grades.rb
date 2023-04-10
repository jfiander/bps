# frozen_string_literal: true

class User
  module RanksAndGrades
    extend ActiveSupport::Concern

    def valid_ranks
      @valid_ranks ||= YAML.safe_load(
        Rails.root.join('app/models/concerns/user/valid_ranks.yml').read
      )
    end

    def valid_grades
      %w[S P AP JN N SN]
    end

    def auto_rank(html: true)
      highest_rank(*ranks(html: html))
    end

    def stripe_rank
      r = ranks(html: false)
      r << 'Stf/C' if mm.to_i >= 50
      highest_rank(*r)&.gsub('/', '')&.gsub(/1(st)?Lt/, 'FirstLt')&.downcase
    end

    def first_stripe_class
      case stripe_rank
      when User::Stripes::NATIONAL
        :national
      when User::Stripes::DISTRICT
        :district
      when User::Stripes::SQUADRON
        :squadron
      else
        :hide
      end
    end

    def ranks(html: true)
      [bridge_rank(html: html), override_rank(html: html), committee_rank].compact_blank
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

    def override_rank(html: true)
      return '' if rank_override == 'none'
      return rank_override if rank_override.present?

      cleanup_1st(rank, html: html)
    end

    # html_safe: No user content
    def bridge_rank(html: true)
      case bridge_office_name
      when 'commander'
        'Cdr'
      when *ltc_offices
        'Lt/C'
      when *first_lt_offices
        html ? '1<sup>st</sup>/Lt'.html_safe : '1st/Lt'
      end
    end

    def ltc_offices
      %w[executive administrative educational secretary treasurer]
    end

    def first_lt_offices
      %w[asst_educational asst_secretary]
    end

    def committee_rank
      return 'F/Lt' if 'Flag Lieutenant'.in?(cached_committees.map(&:name))

      'Lt' if cached_standing_committees.present? || cached_committees.present?
    end

    # rubocop:disable Rails/OutputSafety
    # html_safe: No user content
    def cleanup_1st(output_rank, html: true)
      r = output_rank&.gsub(%r{1/}, '1st/')
      html ? r&.gsub('1st', '1<sup>st</sup>')&.html_safe : r
    end
    # rubocop:enable Rails/OutputSafety

    def valid_rank
      return true if rank.nil?
      return true if rank.in? valid_ranks

      errors.add(:rank, "must be nil or in valid_ranks: #{certificate} \"#{rank}\"")
    end

    def valid_grade
      return true if grade.nil?

      self.grade = grade.to_s.upcase
      return true if grade.in? valid_grades

      errors.add(:grade, "must be nil or in valid_grades: #{certificate} \"#{grade}\"")
    end

    def highest_rank(*ranks)
      rp = ranks.map do |r|
        { r => (rank_priority[r] || 100) }
      end

      rp.reduce({}, :merge).min_by { |_, p| p }&.first
    end

    def rank_priority
      @rank_priority ||= YAML.safe_load(Rails.root.join('app/lib/rank_priority.yml').read)
    end
  end
end
