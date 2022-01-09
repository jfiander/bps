# frozen_string_literal: true

module Voting
  class Vote < ApplicationRecord
    belongs_to :ballot

    before_save { raise Voting::Election::ClosedElection unless ballot.election.open? }

    validate :validate_preference
    validate :validate_selection

    def validate_preference
      case ballot.election.style
      when 'preference'
        enforce_valid_preference
      when 'single'
        enforce_nil_preference
      else
        raise "Unrecognized election style: #{ballot.election.style}"
      end
    end

    def enforce_valid_preference
      errors.add(:preference, 'must be greater than 0') unless preference.positive?
      return unless preference.in?(ballot.votes.reload.map(&:preference))

      errors.add(:preference, 'must be unique')
    end

    def enforce_nil_preference
      errors.add(:preference, 'must not be set') unless preference.nil?
    end

    def validate_selection
      case ballot.election.style
      when 'preference'
        enforce_valid_selections
      when 'single'
        enforce_single_vote
      end
    end

    def enforce_valid_selections
      selections = ballot.votes.reload.map(&:selection)
      selections << selection unless persisted?
      return true if selections.size == selections.uniq.size

      errors.add(:selection, 'must be unique')
    end

    def enforce_single_vote
      return true if ballot.votes.empty? || ballot.votes == [self]

      errors.add(:base, 'Can only have one selection')
    end
  end
end
