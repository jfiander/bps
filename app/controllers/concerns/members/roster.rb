# frozen_string_literal: true

module Members::Roster
  def roster
    respond_to do |format|
      format.html
      format.pdf do
        roster_file = files_bucket.download('roster/Birmingham_Power_Squadron_Roster.pdf')
        send_data(roster_file, filename: 'Birmingham Power Squadron Roster.pdf', disposition: :inline)
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

    files_bucket.upload(
      file: roster_params[:roster],
      key: 'roster/Birmingham_Power_Squadron_Roster.pdf'
    )

    flash[:success] = 'Roster file succesfully updated!'
    flash[:notice] = 'There may be a ~24 hour delay in the live file changing.'
    redirect_to root_path
  end

  private

  def roster_params
    params.permit(:roster)
  end
end
