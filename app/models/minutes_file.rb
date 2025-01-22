# frozen_string_literal: true

class MinutesFile < UploadedFile
  scope :ordered, -> { order(year: :asc, month: :asc) }

  validates :year, presence: true
  validates :month, presence: true

  def self.issues
    {
      1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Sum',
      9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
    }
  end

  def issue
    MinutesFile.issues[month]
  end

  def full_issue
    "#{year} #{issue}"
  end

  def permalink
    r = Rails.application.routes.url_helpers
    return r.get_minutes_path(year: year, month: month) unless excom

    r.get_minutes_excom_path(year: year, month: month)
  end
end
