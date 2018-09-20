# frozen_string_literal: true

module Members::Roster
  FILENAME ||= 'roster/Birmingham_Power_Squadron_Roster.pdf'

  def roster
    redirect_to root_path and return unless files_bucket.has?(FILENAME)

    respond_to do |format|
      format.html
      format.pdf do
        roster_file = files_bucket.download(FILENAME)
        send_data(roster_file, filename: FILENAME.dup.tr('_', ' '), disposition: :inline)
      end
    end
  end

  def update_roster
    #
  end

  def upload_roster
    if roster_params[:roster].blank? || roster_params[:roster].content_type != 'application/pdf'
      flash[:alert] = 'You must upload a valid file.'
      redirect_to update_roster_path
      return
    end

    files_bucket.upload(file: roster_params[:roster], key: FILENAME)

    flash[:success] = 'Roster file succesfully updated!'
    flash[:notice] = 'There may be a ~24 hour delay in the live file changing.'
    redirect_to root_path
  end

  def roster_gen
    respond_to do |format|
      format.pdf { generate_and_send_roster }
      format.html { redirect_to roster_gen_path(format: :pdf) }
    end
  end

  private

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
    send_file(
      RosterPDF.send(roster_orientation, include_blank: roster_params[:include_blank].present?),
      disposition: :inline,
      filename: "Birmingham Power Squadron - #{Date.today.strftime('%Y')} Roster.pdf"
    )
  end
end
