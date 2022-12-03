# frozen_string_literal: true

module Members
  module Announcements
    def upload_announcement
      create_announcement

      redirect_to(
        newsletter_path,
        success: 'Announcement uploaded successfully.'
      )
    end

    def hide_announcement
      AnnouncementFile.find(announcement_params[:id]).hide!

      redirect_to(
        newsletter_path,
        success: 'Announcement hidden successfully.'
      )
    end

    def unhide_announcement
      AnnouncementFile.find(announcement_params[:id]).unhide!

      redirect_to(
        newsletter_path,
        success: 'Announcement unhidden successfully.'
      )
    end

    def remove_announcement
      AnnouncementFile.find_by(
        id: announcement_params[:id]
      )&.destroy

      redirect_to(
        newsletter_path,
        success: 'Announcement removed successfully.'
      )
    end

  private

    def announcement_params
      params.permit(:id, :title, :file)
    end

    def create_announcement
      AnnouncementFile.create(
        title: announcement_params[:title],
        file: announcement_params[:file]
      )
    end
  end
end
