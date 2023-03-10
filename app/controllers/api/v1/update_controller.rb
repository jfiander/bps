# frozen_string_literal: true

module Api
  module V1
    class UpdateController < ApplicationController
      REQUIRED_ROLES = %i[users].freeze

      authenticate_user!

      after_action :join_thread, only: %i[queue_update queue_dryrun]

      def automatic_update(silent: false, dryrun: false)
        updater = AutomaticUpdate::Run.new
        @import_proto = updater.update
        @log_timestamp = updater.log_timestamp
        @import_log_id = updater.import_log_id
        import_success(silent: silent, dryrun: dryrun)
      rescue StandardError => e
        import_failure(e, silent: silent, dryrun: dryrun)
      end

      def queue_update
        @thread = Thread.new { automatic_update(silent: true) }
        render(json: { status: 'Queued automatic update.' }, status: :accepted)
      end

      def queue_dryrun
        @thread = Thread.new { automatic_update_dryrun }
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
        render(json: @import_proto.to_json, status: :ok) unless silent
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
          fields: fields(by, dryrun, update_results, type)
        ).notify!

        return if update_results == 'No changes' || type != :success

        BPS::SlackFile.new('Update Results', update_results).call
      end

      def fields(by, dryrun, update_results, type)
        f = [
          { title: 'By', value: by, short: true },
          { title: 'Via', value: 'API', short: true }
        ]
        f += live_results_fields unless dryrun
        f += dryrun_fields if dryrun && update_results != 'No changes' && type == :success
        f
      end

      def live_results_fields
        [
          { title: 'S3 Log Timestamp', value: @log_timestamp, short: true },
          {
            title: 'Import Log',
            value: "<#{admin_import_log_url(id: @import_log_id)}|Import ##{@import_log_id}>",
            short: true
          }
        ]
      end

      def dryrun_fields
        [
          {
            title: 'Apply Changes?',
            value: "<#{automatic_update_url}|Apply>",
            short: true
          }
        ]
      end

      def update_results
        @import_proto.empty? ? 'No changes' : @import_proto.to_json
      end

      def log_import(by: nil)
        log = File.open("#{Rails.root}/log/user_import.log", 'a')

        log.write("[#{Time.now}] User import by: #{by}\n")
        log.write(@import_proto.to_json)
        log.write("\n\n")
        log.close
      end

      def join_thread
        @thread.join
      end
    end
  end
end
