# frozen_string_literal: true

class AnnouncementFile < UploadedFile
  scope :ordered, -> { order(:created_at) }

  def permalink
    Rails.application.routes.url_helpers.announcement_path(id: id)
  end
end
