# frozen_string_literal: true

class BilgeFile < UploadedFile
  AVAILABLE_ISSUES = {
    1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun',
    's' => 'Sum', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
  }.freeze

  def self.bucket
    :bilge
  end

  def self.path_pattern
    ':id/Bilge_Chatter.pdf'
  end

  has_attached_file(:file, paperclip_defaults(bucket).merge(path: path_pattern))

  validates :year, presence: true
  validates :month, presence: true

  scope :ordered, -> { order(year: :asc, month: :asc) }
  scope :last_18, -> { order(year: :desc, month: :desc).limit(18) }

  def self.issues
    {
      1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun',
      7 => 'Sum', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
    }
  end

  def issue
    BilgeFile.issues[month]
  end

  def full_issue
    "#{year} #{issue}"
  end

  def permalink
    Rails.application.routes.url_helpers.bilge_path(year: year, month: month)
  end
end
