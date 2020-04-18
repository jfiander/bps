# frozen_string_literal: true

class AnnouncementFile < UploadedFile
  has_attached_file(
    :file, paperclip_defaults(:files).merge(path: 'announcements/:id.pdf')
  )

  scope :ordered, -> { order(:created_at) }

  def link
    self.class.buckets[:files].link(file.s3_object.key)
  end

  def invalidate!
    Invalidation.submit(:files, "/#{id}.pdf")
  end
end
