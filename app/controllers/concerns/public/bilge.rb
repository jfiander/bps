# frozen_string_literal: true

module Public::Bilge
  def get_bilge
    key = "#{clean_params[:year]}/#{clean_params[:month]}"
    issue_link = @bilge_links[key]
    issue_title = key.tr('/', '-')

    if issue_link.blank?
      newsletter
      flash.now[:alert] = 'There was a problem accessing the Bilge Chatter.'
      flash.now[:error] = 'Issue not found.'
      render :newsletter
      return
    end

    begin
      send_data(
        open(issue_link).read,
        filename: "Bilge Chatter #{issue_title}.pdf",
        type: 'application/pdf',
        disposition: 'inline'
      )
    rescue SocketError
      newsletter
      flash.now[:alert] = 'There was a problem accessing the Bilge Chatter. Please try again later.'
      render :newsletter
    end
  end

  private

  def list_bilges
    @bilges = bilge_bucket.list

    @bilge_links = @bilges.map(&:key).map do |b|
      { b.delete('.pdf') => bilge_bucket.link(b) }
    end.reduce({}, :merge)
  end

  def bilge_years
    @bilges
      .map(&:key)
      .map { |b| b.sub('.pdf', '').sub(%r{/(s|\d+)$}, '').delete('/') }
      .uniq
      .reject(&:blank?)
  end

  def available_bilge_issues
    {
      1   => 'Jan',
      2   => 'Feb',
      3   => 'Mar',
      4   => 'Apr',
      5   => 'May',
      6   => 'Jun',
      's' => 'Sum',
      9   => 'Sep',
      10  => 'Oct',
      11  => 'Nov',
      12  => 'Dec'
    }
  end
end
