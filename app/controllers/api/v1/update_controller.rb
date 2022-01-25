# frozen_string_literal: true

module Api
  module V1
    class UpdateController < ApplicationController
      secure!(:users)

      def automatic_update
        @import_results = AutomaticUpdate::Run.new.update
        import_success
      rescue StandardError => e
        import_failure(e)
      end

    private

      # Adapted from User::Import controller concern
      def import_success
        import_notification(:success)
        log_import
        render(json: @import_results, status: :ok)
      end

      def import_failure(error)
        import_notification(:failure)
        render(
          json: { error: 'Automatic update failed.', message: error.message },
          status: :unprocessable_entity
        )
      end

      def import_notification(type)
        title = type == :success ? 'Complete' : 'Failed'
        fallback = type == :success ? 'successfully imported' : 'failed to import'
        SlackNotification.new(
          channel: :notifications, type: type, title: "User Data Import #{title}",
          fallback: "User information has #{fallback}.",
          fields: [
            { title: 'By', value: current_user.full_name, short: true },
            { title: 'Results', value: @import_results.to_s, short: false }
          ]
        ).notify!
      end

      def log_import
        log = File.open("#{Rails.root}/log/user_import.log", 'a')

        log.write("[#{Time.now}] User import by: #{current_user.full_name}\n")
        log.write(@import_results)
        log.write("\n\n")
        log.close
      end
    end
  end
end
