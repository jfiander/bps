# frozen_string_literal: true

module Voting
  class Candidate < ApplicationRecord
    belongs_to :election
  end
end
