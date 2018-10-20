# frozen_string_literal: true

class ImportLog < ApplicationRecord
  def self.latest
    all.order(:created_at).last
  end
end
