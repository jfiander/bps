# frozen_string_literal: true

module Concerns
  module Application
    module RedirectWithStatus
      # This module defines no public methods.
      def _; end

    private

      def redirect_with_status(path, options = {})
        redirect_if(yield, path, options) do
          redirect_to(
            path,
            alert: "Unable to #{options[:verb]} #{options[:object]}.",
            error: errors(options[:ivar], options[:object])
          )
        end
      end

      def redirect_or_render_error(path, options = {})
        redirect_if(yield, path, options) do
          flash.now[:alert] = "Unable to #{options[:verb]} #{options[:object]}."
          flash.now[:error] = errors(options[:ivar], options[:object])
          render(options[:render_method])
        end
      end

      def redirect_if(condition, path, options)
        if condition
          past = options[:past] || "#{options[:verb]}d"
          redirect_to(path, success: "Successfully #{past} #{options[:object]}.")
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
  end
end
