# frozen_string_literal: true

module Concerns::Application::RedirectWithStatus
  private

  def redirect_with_status(path, object:, verb:, past: nil, ivar: nil)
    redirect_if(yield, path, verb, past, object) do
      redirect_to(
        path,
        alert: "Unable to #{verb} #{object}.",
        error: errors(ivar, object)
      )
    end
  end

  def redirect_or_render_error(path, render_method:, object:, verb:, past: nil, ivar: nil)
    redirect_if(yield, path, verb, past, object) do
      flash.now[:alert] = "Unable to #{verb} #{object}."
      flash.now[:error] = errors(ivar, object)
      render render_method
    end
  end

  def redirect_if(condition, path, verb, past, object)
    if condition
      past ||= "#{verb}d"
      redirect_to(path, success: "Successfully #{past} #{object}.")
    else
      yield
    end
  end

  def errors(ivar, object)
    ivar ||= instance_variable_get("@#{object}")
    ivar&.errors&.full_messages
  rescue StandardError
    nil
  end
end
