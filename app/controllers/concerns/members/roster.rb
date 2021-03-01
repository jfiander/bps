# frozen_string_literal: true

module Members
  module Roster
    ROSTER_UPLOAD_RETRY_EXCEPTIONS ||= [
      Aws::S3::Errors::BadDigest, Aws::S3::Errors::XAmzContentSHA256Mismatch
    ].freeze

    included do
      before_action :redirect_if_no_roster, only: :roster
      before_action :reject_invalid_file, only: :upload_roster
    end

    def roster
      respond_to do |format|
        format.html
        format.pdf do
          roster_file = files_bucket.download("roster/#{roster_filename}")
          send_data(roster_file, filename: roster_filename.dup.tr('_', ' '), disposition: :inline)
        end
      end
    end

    def update_roster; end

    def upload_roster
      files_bucket.upload(file: roster_params[:roster], key: "roster/#{roster_filename}")
      Invalidation.submit(:files, "roster/#{roster_filename}")

      flash[:success] = 'Roster file succesfully updated!'
      flash[:notice] = 'There may be a delay in the live file changing.'
      redirect_to root_path
    end

    def roster_gen
      respond_to do |format|
        format.pdf { generate_and_send_roster }
        format.html { redirect_to roster_gen_path(format: :pdf) }
      end
    end

  private

    def reject_invalid_file
      return unless roster_params[:roster].present?
      return unless roster_params[:roster].content_type == 'application/pdf'

      flash[:alert] = 'You must upload a valid file.'
      redirect_to update_roster_path
    end

    def redirect_if_no_roster
      redirect_to root_path unless files_bucket.has?("roster/#{roster_filename}")
    end

    def roster_filename
      "Birmingham_Power_Squadron_-_#{Date.today.strftime('%Y')}_Roster.pdf"
    end

    def roster_params
      params.permit(:roster, :orientation, :include_blank)
    end

    def roster_orientation
      if roster_params[:orientation].in?(%w[portrait landscape detailed])
        roster_params[:orientation]
      else
        'portrait'
      end
    end

    def generate_and_send_roster
      pdf = BpsPdf::Roster.send(
        roster_orientation, include_blank: roster_params[:include_blank].present?
      )

      send_file(pdf, disposition: :inline, filename: roster_filename)

      ExpRetry.for(exception: ROSTER_UPLOAD_RETRY_EXCEPTIONS) do
        upload_roster_to_s3(pdf.read)
      end
    end

    def upload_roster_to_s3(pdf)
      pdf_file = File.open("#{Rails.root}/tmp/run/roster.pdf", 'w+')
      pdf_file.write(pdf)
      pdf_file.rewind

      pdf_file = File.open("#{Rails.root}/tmp/run/roster.pdf", 'r+')
      files_bucket.upload(file: pdf_file, key: "roster/#{roster_filename}")
      Invalidation.submit(:files, "roster/#{roster_filename}")
    end
  end
end
