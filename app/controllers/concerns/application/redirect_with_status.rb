# frozen_string_literal: true

module Concerns::Application::RedirectWithStatus
  private

  def redirect_with_status(path, object:, verb:, past: nil, ivar: nil)
    past ||= "#{verb}d"
    if yield
      redirect_to(path, success: "Successfully #{past} #{object}.")
    else
      redirect_to(
        path,
        alert: "Unable to #{verb} #{object}.",
        error: errors(ivar, object)
      )
    end
  end

  def errors(ivar, object)
    ivar ||= instance_variable_get("@#{object}")
    ivar&.errors&.full_messages
  rescue StandardError
    nil
  end
end
