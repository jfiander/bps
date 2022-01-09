# frozen_string_literal: true

module Voting
  class Election < ApplicationRecord
    STYLES = %w[single preference].freeze
    RESTRICTIONS = HashWithIndifferentAccess[{ executive: :excom }].freeze

    has_many :candidates # With no Candidates available, the election should be a simple Yes/No vote
    has_many :ballots
    has_many :users, through: :ballots

    before_validation do
      self.style = style.to_s
      self.restriction = restriction.to_s
    end

    validates :style, inclusion: STYLES
    validates :restriction, inclusion: { in: RESTRICTIONS.keys.map(&:to_s) }, allow_blank: true

    def restricted?
      restriction.present?
    end

    def open?
      open_at.present? && open_at < Time.now && !closed?
    end

    def closed?
      closed_at.present? && closed_at < Time.now
    end

    def compliant?
      return unless restriction == 'executive'

      bridge = BridgeOffice.all.to_a
      excom = bridge + StandingCommitteeOffice.executive.to_a

      users == excom.map(&:user).compact.uniq
    end

    def immediate!
      update!(open_at: Time.now, closed_at: Time.now + 1.hour)
      self
    end

    def open!
      update!(open_at: Time.now)
      self
    end

    def close!
      update!(closed_at: Time.now)
      self
    end

    def results
      send("#{style}_results")
    end

  private

    def single_results
      votes = ballots.flat_map(&:votes)
      grouped = votes.group_by(&:selection)
      res = grouped.transform_values(&:count)

      Hash[res.sort_by { |_k, v| v }.reverse] # Sort by counts, descending
    end

    def preference_results
      raise 'Not yet supported'
    end

    class ClosedElection < StandardError; end
  end
end
