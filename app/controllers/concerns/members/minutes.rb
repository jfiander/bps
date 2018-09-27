# frozen_string_literal: true

module Members::Minutes
  def minutes
    @minutes = MinutesFile.ordered.where(excom: false).group_by(&:year)
    @excom_minutes = MinutesFile.ordered.where(excom: true).group_by(&:year)

    @years = (@minutes.keys + @excom_minutes.keys).flatten.uniq.sort
    @issues = MinutesFile.issues
  end

  def find_minutes
    minute = MinutesFile.find_by(
      year: minutes_params[:year].to_i, month: minutes_params[:month].to_i,
      excom: params[:excom].present?
    )

    return minute_not_found unless minute.present?

    send_minute(minute, excom: params[:excom].present?)
  end

  def upload_minutes
    verb = update_file(:minutes)

    redirect_to(
      minutes_path,
      success: "Minutes #{@issue} #{verb} successfully."
    )
  end

  private

  def list_minutes
    @minutes = MinutesFile.ordered.where(excom: false).group_by(&:year)
    @excom_minutes = MinutesFile.ordered.where(excom: true).group_by(&:year)

    @issues = MinutesFile.issues
    @years = (@minutes.keys + @excom_minutes.keys).flatten.uniq.sort
  end

  def find_minutes_issue
    MinutesFile.find_by(
      year: minutes_params[:issue]['date(1i)'],
      month: minutes_params[:issue]['date(2i)'],
      excom: minutes_params[:minutes_excom].present?
    )
  end

  def minute_not_found
    redirect_to(minutes_path, alert: 'Minutes not found.')
  end

  def send_minute(minute, excom: false)
    e = excom ? 'ExCom ' : ''
    send_data(
      URI.parse(files_bucket.link(minute.file.s3_object.key)).open.read,
      filename: "BPS #{e}Minutes - #{minute.year} #{minute.issue}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
    )
  end

  def minutes_params
    params.permit(
      :file, :minutes_remove, :minutes_excom, :year, :month,
      issue: ['date(1i)', 'date(2i)']
    )
  end

  def update_minutes
    if minutes_params[:minutes_remove].present?
      remove_minutes
      'removed'
    elsif (minutes = find_minutes_issue).present?
      minutes.update(file: minutes_params[:file])
      'replaced'
    else
      create_minutes
      'uplodaed'
    end
  end

  def remove_minutes
    MinutesFile.find_by(
      year: minutes_params[:issue]['date(1i)'],
      month: minutes_params[:issue]['date(2i)'],
      excom: minutes_params[:minutes_excom].present?
    ).destroy
  end

  def create_minutes
    MinutesFile.create(
      year: minutes_params[:issue]['date(1i)'],
      month: minutes_params[:issue]['date(2i)'],
      excom: minutes_params[:minutes_excom].present?,
      file: minutes_params[:file]
    )
  end
end
