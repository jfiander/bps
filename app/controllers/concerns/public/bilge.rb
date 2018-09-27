# frozen_string_literal: true

module Public::Bilge
  def newsletter
    @public_ids = BilgeFile.last_18.map(&:id)
    @issues = BilgeFile.issues
  end

  def bilge
    bilge = pick_bilge

    return bilge_not_found unless bilge.present?

    send_bilge(bilge.file, "#{bilge.year} - #{bilge.month}")
  end

  private

  def list_bilges
    @bilges = user_signed_in? ? BilgeFile.ordered : BilgeFile.last_18
  end

  def pick_bilge
    @bilges.select do |b|
      b.year == clean_params[:year].to_i && b.month == clean_params[:month].to_i
    end.first
  end

  def bilge_not_found
    newsletter
    flash.now[:alert] = 'There was a problem accessing the Bilge Chatter.'
    flash.now[:error] = 'Issue not found.'
    render :newsletter
  end

  def send_bilge(file, issue)
    send_data(
      URI.parse(bilge_bucket.link(file.s3_object.key)).open.read,
      filename: "Bilge Chatter #{issue}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
    )
  rescue SocketError
    newsletter
    flash.now[:alert] = 'There was a problem accessing the Bilge Chatter. Please try again later.'
    render :newsletter
  end

  def available_bilge_issues
    {
      1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun',
      's' => 'Sum', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
    }
  end
end
