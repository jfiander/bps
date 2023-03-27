# frozen_string_literal: true

class Jobcode < ApplicationRecord
  belongs_to :user

  scope :squadron, -> { where('jobcodes.jobcode LIKE "3%"') }
  scope :district, -> { where('jobcodes.jobcode LIKE "2%"') }
  scope :national, -> { where('jobcodes.jobcode LIKE "1%"') }
  scope :current, -> { where(year: Time.zone.today.year) }

  def current?
    year == Time.zone.today.year
  end

  def level
    { '1' => :national, '2' => :district, '3' => :squadron }[code[0]]
  end

  def to_s
    "#{code}\t#{year}#{'*' unless current?}\t#{level}\t#{description}"
  end
end
