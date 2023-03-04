# frozen_string_literal: true

class AnnouncementFile < UploadedFile
  scope :ordered, -> { order(:created_at) }
  scope :visible, -> { where(hidden_at: nil) }

  def permalink
    Rails.application.routes.url_helpers.v2_announcement_path(id: id)
  end

  def hidden?
    hidden_at.present?
  end

  def hide!
    update(hidden_at: Time.zone.now)
  end

  def unhide!
    update(hidden_at: nil)
  end
end
