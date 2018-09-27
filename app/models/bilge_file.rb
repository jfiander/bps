# frozen_string_literal: true

class BilgeFile < UploadedFile
  has_attached_file(
    :file, paperclip_defaults(:bilge).merge(path: ':id/Bilge_Chatter.pdf')
  )

  scope :ordered, -> { order(year: :asc, month: :asc) }
  scope :last_18, -> { order(year: :desc, month: :desc).limit(18) }

  def self.issues
    {
      1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun',
      7 => 'Sum', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
    }
  end

  def self.last_18_ids
    last_18.map(&:id)
  end

  def issue
    BilgeFile.issues[month]
  end

  def key
    file.s3_object.key
  end
end
