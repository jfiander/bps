# frozen_string_literal: true

class BilgeFile < UploadedFile
  has_attached_file(
    :file, paperclip_defaults(:bilge).merge(path: ':id/Bilge_Chatter.pdf')
  )

  validates :year, presence: true
  validates :month, presence: true

  scope :ordered, -> { order(year: :asc, month: :asc) }
  scope :last_18, -> { order(year: :desc, month: :desc).limit(18) }

  after_create { send_notification }

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

  def link
    self.class.buckets[:bilge].link(file.s3_object.key)
  end

  private

  def send_notification
    SlackNotification.new(
      type: :info, title: 'Bilge Chatter Uploaded',
      fallback: 'A new issue of The Bilge Chatter has been uploaded.',
      fields: {
        'Issue' => full_issue,
        'Link' => "<#{link}|Bilge Chatter>"
      }
    ).notify!
  end
end
