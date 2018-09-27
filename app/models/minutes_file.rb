# frozen_string_literal: true

class MinutesFile < UploadedFile
  scope :ordered, -> { order(year: :asc, month: :asc) }

  def self.issues
    {
      1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun',
      9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
    }
  end

  def issue
    MinutesFile.issues[month]
  end

  def key
    file.s3_object.key
  end
end
