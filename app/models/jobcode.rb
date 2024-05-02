# frozen_string_literal: true

class Jobcode < ApplicationRecord
  belongs_to :user

  scope :squadron, -> { where('jobcodes.code LIKE "3%"') }
  scope :district, -> { where('jobcodes.code LIKE "2%"') }
  scope :national, -> { where('jobcodes.code LIKE "1%"') }
  scope :current, -> { where(current: true) }
  scope :current_year, -> { where(year: Time.zone.today.year) }

  def current_year?
    year == Time.zone.today.year
  end

  def level
    { '1' => :national, '2' => :district, '3' => :squadron }[code[0]]
  end

  def to_s
    "#{code}\t#{year}#{'*' unless current_year?}\t#{level}\t#{description}"
  end

  def to_proto
    BPS::Update::JobCode.new(
      user: {
        id: user_id,
        certificate: user.certificate,
        name: user.simple_name
      },
      code: code,
      year: year,
      description: description,
      acting: acting
    )
  end
end
