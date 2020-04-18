# frozen_string_literal: true

module Public
  module Announcements
    def announcement_direct
      af = AnnouncementFile.find_by(id: announcement_params[:id])
      return announcement_not_found unless af.present?

      send_announcement(af)
    end

  private

    def announcement_params
      params.permit(:id)
    end

    def load_announcements
      @announcements = AnnouncementFile.ordered
    end

    def announcement_not_found
      error_redirect_to_newsletter('There was a problem accessing that announcement.')
    end

    def send_announcement(file)
      send_data(
        URI.parse(files_bucket.link(file.file.s3_object.key)).open.read,
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
