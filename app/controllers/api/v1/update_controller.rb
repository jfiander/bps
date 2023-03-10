# frozen_string_literal: true

module Api
  module V1
    class UpdateController < ApplicationController
      REQUIRED_ROLES = %i[users].freeze

      authenticate_user!

      def automatic_update(dryrun: false, silent: false)
        result = AutomaticUpdateJob.new.perform(current_user.id, dryrun: dryrun)
        return if silent

        if result == :success
          render(json: @import_proto.to_json, status: :ok)
        else
          render(
            json: { error: 'Automatic update failed.', message: result.message },
            status: :unprocessable_entity
          )
        end
      end

      def queue_update
        AutomaticUpdateJob.perform_later(current_user.id, dryrun: false)
        render(json: { status: 'Queued automatic update.' }, status: :accepted)
      end

      def queue_dryrun
        AutomaticUpdateJob.perform_later(current_user.id, dryrun: true)
        render(json: { status: 'Queued automatic update dryrun.' }, status: :accepted)
      end
    end
  end
end
