# frozen_string_literal: true

module Members::Bilge
  def upload_bilge
    verb = update_bilge

    redirect_to(
      newsletter_path,
      success: "Bilge Chatter #{@issue} #{verb} successfully."
    )
  end

  private

  def find_bilge
    BilgeFile.find_by(
      year: bilge_params[:issue]['date(1i)'],
      month: bilge_params[:issue]['date(2i)']
    )
  end

  def bilge_params
    params.permit(
      :id, :page_name, :save, :preview, :file, :bilge_remove,
      issue: ['date(1i)', 'date(2i)']
    )
  end

  def update_bilge
    if bilge_params[:bilge_remove].present?
      remove_bilge
      'removed'
    elsif (bilge = find_bilge).present?
      bilge.update(file: bilge_params[:file])
      'replaced'
    else
      create_bilge
      'uplodaed'
    end
  end

  def remove_bilge
    BilgeFile.find_by(
      year: bilge_params[:issue]['date(1i)'],
      month: bilge_params[:issue]['date(2i)']
    ).destroy
  end

  def create_bilge
    BilgeFile.create(
      year: bilge_params[:issue]['date(1i)'],
      month: bilge_params[:issue]['date(2i)'],
      file: bilge_params[:file]
    )
  end
end
