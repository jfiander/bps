# frozen_string_literal: true

class OTWTrainingUser < ApplicationRecord
  belongs_to :user
  belongs_to :otw_training
end
