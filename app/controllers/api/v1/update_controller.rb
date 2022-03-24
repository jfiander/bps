# frozen_string_literal: true

module Api
  module V1
    class UpdateController < Api::V1::ApplicationController
      REQUIRED_ROLES = %i[users].freeze

      authenticate_user!

      def automatic_update(silent: false, dryrun: false)
        @import_results = AutomaticUpdate::Run.new.update
        import_success(silent: silent, dryrun: dryrun)
      rescue StandardError => e
        import_failure(e, silent: silent, dryrun: dryrun)
      end

      def queue_update
        Thread.new { automatic_update(silent: true) }
        render(json: { status: 'Queued automatic update.' }, status: :accepted)
      end

      def queue_dryrun
        Thread.new { automatic_update_dryrun }
        render(json: { status: 'Queued automatic update dryrun.' }, status: :accepted)
      end

    private

      def automatic_update_dryrun
        User.transaction do
          automatic_update(silent: true, dryrun: true)
          raise ActiveRecord::Rollback
        end
      end

      # Adapted from User::Import controller concern
      def import_success(silent: false, dryrun: false)
        by = current_user ? current_user.full_name : 'API'
        import_notification(:success, by: by, dryrun: dryrun)
        log_import(by: by) unless dryrun
        render(json: @import_results, status: :ok) unless silent
      end

      def import_failure(error, silent: false, dryrun: false)
        import_notification(:failure, dryrun: dryrun)
        return if silent

        render(
          json: { error: 'Automatic update failed.', message: error.message },
          status: :unprocessable_entity
        )
      end

      def import_notification(type, by: nil, dryrun: false)
        title = type == :success ? 'Complete' : 'Failed'
        fallback = type == :success ? 'successfully imported' : 'failed to import'
        dry = dryrun ? '[Dryrun] ' : ''
        SlackNotification.new(
          channel: :notifications, type: type, title: "#{dry}User Data Import #{title}",
          fallback: "#{dry}User information has #{fallback}.",
          fields: [
            { title: 'By', value: by, short: true },
            ({ title: 'Dryrun', value: 'true', short: true } if dryrun),
            { title: 'Results', value: @import_results.to_s, short: false }
          ].compact
        ).notify!
      end

      def log_import(by: nil)
        log = File.open("#{Rails.root}/log/user_import.log", 'a')

        log.write("[#{Time.now}] User import by: #{by}\n")
        log.write(@import_results)
        log.write("\n\n")
        log.close
      end
    end
  end
end
