# frozen_string_literal: true

module Members
  module Roster
    ROSTER_UPLOAD_RETRY_EXCEPTIONS ||= [
      Aws::S3::Errors::BadDigest, Aws::S3::Errors::XAmzContentSHA256Mismatch
    ].freeze

    def roster
      respond_to do |format|
        format.html { roster_filename }
        format.pdf do
          roster_file = BPS::S3.new(:files).download("roster/#{roster_filename}")
          send_data(roster_file, filename: roster_filename.dup.tr('_', ' '), disposition: :inline)
        end
      end
    end

    def update_roster; end

    def upload_roster
      BPS::S3.new(:files).upload(
        file: roster_params[:roster],
        key: "roster/#{roster_filename}",
        content_type: 'application/pdf'
      )
      BPS::Invalidation.submit(:files, "roster/#{roster_filename}")

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

    # Always returns the most recent already-existing roster filename
    def roster_filename
      return @roster_filename if @roster_filename

      @year ||= Date.today.strftime('%Y').to_i

      filename = "Birmingham_Power_Squadron_-_#{@year}_Roster.pdf"
      return filename if BPS::S3.new(:files).has?("roster/#{filename}")

      @year -= 1
      redirect_to root_path if @year < Date.today.strftime('%Y').to_i - 3

      @roster_filename = roster_filename
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
      pdf = BPS::PDF::Roster.send(
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

      year = Date.today.strftime('%Y').to_i
      new_roster_filename = "Birmingham_Power_Squadron_-_#{year}_Roster.pdf"

      BPS::S3.new(:files).upload(file: pdf_file, key: "roster/#{new_roster_filename}")
      BPS::Invalidation.submit(:files, "roster/#{new_roster_filename}")
    end
  end
end
