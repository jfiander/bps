# frozen_string_literal: true

module V2
  class AnnouncementsController < ApplicationController
    secure!(:newsletter, only: %i[create destroy hide unhide])

    before_action :load_announcement, only: %i[show destroy hide unhide]

    def show
      return announcement_not_found if @announcement.blank?

      send_announcement(@announcement)
    end

    def create
      AnnouncementFile.create(
        title: announcement_params[:title],
        file: announcement_params[:file]
      )

      redirect_to(
        newsletter_path,
        success: 'Announcement uploaded successfully.'
      )
    end

    def destroy
      @announcement.destroy

      redirect_to(v2_bilges_path, success: 'Announcement removed successfully.')
    end

    def hide
      @announcement.hide!

      redirect_to(v2_bilges_path, success: 'Announcement hidden successfully.')
    end

    def unhide
      @announcement.unhide!

      redirect_to(v2_bilges_path, success: 'Announcement unhidden successfully.')
    end

  private

    def announcement_params
      params.permit(:id, :title, :file)
    end

    def load_announcement
      @announcement = AnnouncementFile.find(announcement_params[:id])
    end

    def announcement_not_found
      error_redirect_to_newsletter('There was a problem accessing that announcement.')
    end

    def send_announcement(file)
      send_data(
        URI.parse(BPS::S3.new(:files).link(file.file.s3_object.key)).open.read,
        filename: "BPS Announcement - #{file.title}.pdf",
        type: 'application/pdf',
        disposition: 'inline'
      )
    rescue SocketError
      error_redirect_to_newsletter('There was a problem accessing that announcement.')
    end

    def error_redirect_to_newsletter(message)
      flash[:alert] = message
      redirect_to(newsletter_path)
    end
  end
end
