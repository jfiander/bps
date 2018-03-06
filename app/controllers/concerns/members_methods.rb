module MembersMethods
  def minutes
    minutes_years = @minutes.map(&:key).map do |b|
      b.sub("#{minutes_prefix}/", '').delete('.pdf').gsub(%r{/(s|\d+)}, '')
    end
    minutes_excom_years = @minutes_excom.map(&:key).map do |b|
      b.sub("#{minutes_prefix(excom: true)}/", '').delete('.pdf')
       .gsub(%r{/(s|\d+)}, '')
    end

    @years = [minutes_years, minutes_excom_years].flatten.uniq
    @issues = @minutes_links.keys
    @issues_excom = @minutes_excom_links.keys
    @available_issues = {
      1   => 'Jan',
      2   => 'Feb',
      3   => 'Mar',
      4   => 'Apr',
      5   => 'May',
      6   => 'Jun',
      9   => 'Sep',
      10  => 'Oct',
      11  => 'Nov',
      12  => 'Dec'
    }
  end

  def get_minutes
    key = [
      minutes_prefix, minutes_params[:year], minutes_params[:month]
    ].join('/')
    issue_link = @minutes_links[key.sub("#{minutes_prefix}/", '')]
    issue_title = key.tr("/", "-")

    send_minutes_file(title: issue_title, link: issue_link)
  end

  def get_minutes_excom
    key = [
      minutes_prefix(excom: true), minutes_params[:year], minutes_params[:month]
    ].join('/')
    issue_link = @minutes_excom_links[key.sub("#{minutes_prefix(excom: true)}/", '')]
    issue_title = key.tr('/', '-')

    send_minutes_file(title: issue_title, link: issue_link, excom: true)
  end

  def upload_minutes
    unless valid_upload?(type: :minutes)
      redirect_to(
        minutes_path, alert: 'You must either upload a file or select remove.'
      )
      return
    end

    remove_minutes and return if minutes_params[:minutes_remove].present?

    files_bucket.upload(file: minutes_params[:minutes_upload_file], key: @key)
    redirect_to(
      minutes_path, success: "Minutes #{@issue} uploaded successfully."
    )
  end

  def upload_bilge
    unless valid_upload?(type: :bilge)
      redirect_to(
        newsletter_path,
        alert: 'You must either upload a file or check the remove box.'
      )
      return
    end
    remove_bilge and return if bilge_params[:bilge_remove].present?

    bilge_bucket.upload(file: bilge_params[:bilge_upload_file], key: @key)
    redirect_to(
      newsletter_path, success: "Bilge Chatter #{@issue} uploaded successfully."
    )
  end

  private

  def bilge_params
    params.permit(
      :id, :page_name, :save, :preview, :bilge_upload_file, :bilge_remove,
      issue: ['date(1i)', 'date(2i)']
    )
  end

  def minutes_params
    params.permit(
      :minutes_upload_file, :minutes_remove, :minutes_excom, :year, :month,
      issue: ['date(1i)', 'date(2i)']
    )
  end

  def valid_upload?(type: :bilge)
    if type == :bilge
      bilge_params[:bilge_upload_file] || bilge_params[:bilge_remove]
    elsif type == :minutes
      minutes_params[:minutes_upload_file] || minutes_params[:minutes_remove]
    end
  end

  def bilge_issue
    @year = bilge_params[:issue]['date(1i)']
    month = bilge_params[:issue]['date(2i)']
    @month = month.to_i.in?([7,8]) ? 's' : month
    @issue = "#{@year}/#{@month}"
    @key = "#{@issue}.pdf"
  end

  def remove_bilge
    bilge_bucket.remove_object(@key)
    redirect_to(
      newsletter_path,
      success: "Bilge Chatter #{@issue} removed successfully."
    )
  end

  def remove_minutes
    files_bucket.remove_object(@key)
    redirect_to minutes_path, success: "Minutes #{@issue} removed successfully."
  end

  def get_minutes_issue
    excom = minutes_params[:minutes_excom]
    @year = minutes_params[:issue]['date(1i)']
    month = minutes_params[:issue]['date(2i)']
    @month = month.to_i.in?([7,8]) ? "s" : month
    @issue = "#{@year}/#{@month}"
    @key = "#{minutes_prefix(excom: excom)}/#{@issue}.pdf"
  end

  def list_minutes
    @minutes = files_bucket.list(minutes_prefix)
    @minutes_excom = files_bucket.list(minutes_prefix(excom: true))

    @minutes_links = @minutes.map do |m|
      key = m.key.dup
      issue_date = m.key.sub("#{minutes_prefix}/", '').delete('.pdf')
      { issue_date => files_bucket.link(key) }
    end.reduce({}, :merge)

    @minutes_excom_links = @minutes_excom.map do |m|
      key = m.key.dup
      issue_date = m.key.sub("#{minutes_prefix(excom: true)}/", '').delete('.pdf')
      { issue_date => files_bucket.link(key) }
    end.reduce({}, :merge)
  end

  def minutes_prefix(excom: false)
    "#{excom ? 'excom_' : ''}minutes"
  end

  def send_minutes_file(title:, link:, excom: false)
    send_data(
      open(link).read,
      filename: "BPS#{excom ? ' ExCom' : ''} Minutes #{title}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
    )
  rescue SocketError
    minutes
    flash.now[:alert] = 'There was a problem accessing the minutes. ' \
                        'Please try again later.'
    render :minutes
  end
end
