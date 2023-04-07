# frozen_string_literal: true

# Code extracted from Api::V1::UpdateController
class AutomaticUpdateJob < ApplicationJob
  queue_as :automatic_update

  attr_reader :import_proto, :log_timestamp, :import_log_id, :error

  def perform(user_id, dryrun:, via: 'API', lock: false)
    @user_id = user_id
    @via = via
    @lock = lock
    dryrun ? automatic_update_dryrun : automatic_update
    self
  end

  def success?
    @success
  end

private

  def by
    user = User.find_by(id: @user_id)
    user ? user.full_name : 'API'
  end

  def updater
    @updater ||= AutomaticUpdate::Run.new
  end

  def automatic_update(dryrun: false)
    @import_proto = updater.update(lock: @lock)
    @log_timestamp = updater.log_timestamp
    @import_log_id = updater.import_log_id
    import_success(dryrun: dryrun)
  rescue StandardError => e
    raise e if Rails.env.development?

    import_failure(e, dryrun: dryrun)
  end

  def automatic_update_dryrun
    User.transaction do
      @result = automatic_update(dryrun: true)
      raise ActiveRecord::Rollback
    end
    @result
  end

  def import_success(dryrun: false)
    import_notification(:success, by: by, dryrun: dryrun)
    @success = true
  end

  def import_failure(error, dryrun: false)
    import_notification(:failure, by: by, dryrun: dryrun, channel: :alarms, error: error)
    @success = false
    @error = error
  end

  def import_notification(type, by: nil, dryrun: false, channel: :auto_updates, error: nil)
    title = type == :success ? 'Complete' : 'Failed'
    fallback = type == :success ? 'successfully imported' : 'failed to import'
    dry = dryrun ? '[Dryrun] ' : ''

    fields = fields(by, dryrun, update_results, type)
    fields << { title: 'Error Message', value: error.message, short: false } if type == :failure

    SlackNotification.new(
      channel: channel, type: type, title: "#{dry}User Data Import #{title}",
      fallback: "#{dry}User information has #{fallback}.",
      fields: fields
    ).notify!

    return if update_results == 'No changes' || type != :success

    BPS::SlackFile.new('Update Results', update_results, channel: channel).call

    changes_available_notification(update_results, by: by) if dryrun
  end

  def changes_available_notification(update_results, by: nil)
    SlackNotification.new(
      channel: :notifications, type: :info, title: 'User Data Changes Available',
      fallback: 'User data changes are available to import.',
      fields: fields(by, true, update_results, :success)
    ).notify!

    BPS::SlackFile.new('Update Results', update_results, channel: :notifications).call
  end

  def fields(by, dryrun, update_results, type)
    f = [
      { title: 'By', value: by, short: true },
      { title: 'Via', value: @via, short: true }
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
    return 'No changes' if @import_proto.empty?

    json = @import_proto.to_json
    return json unless @import_proto.jobcodes.empty?

    # Exclude empty jobcodes from JSON
    JSON.parse(json).tap { |h| h.delete('jobcodes') }.to_json
  end
end
