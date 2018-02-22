module DeviseHelper
  def devise_error_messages!
    return unless devise_error_messages?

    flash[:alert] = alert_sentence
    flash[:error] = resource.errors.full_messages
  end

  def devise_error_messages?
    !resource.errors.empty?
  end

  private

  def alert_sentence
    I18n.t(
      'errors.messages.not_saved',
      count: resource.errors.count,
      resource: resource.class.model_name.human.downcase
    )
  end
end
