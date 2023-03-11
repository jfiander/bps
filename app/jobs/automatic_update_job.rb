# frozen_string_literal: true

# Code extracted from Api::V1::UpdateController
class AutomaticUpdateJob < ApplicationJob
  queue_as :automatic_update

  attr_reader :import_proto, :log_timestamp, :import_log_id, :error

  def perform(user_id, dryrun:, via: 'API')
    @user = User.find_by(id: user_id)
    @via = via
    dryrun ? automatic_update_dryrun : automatic_update
    self
  end

  def success?
    @success
  end

private

  def by
    @user ? @user.full_name : 'API'
  end

  def updater
    @updater ||= AutomaticUpdate::Run.new
  end

  def automatic_update
    @import_proto = updater.update
    @log_timestamp = updater.log_timestamp
    @import_log_id = updater.import_log_id
    import_success(dryrun: false)
  rescue StandardError => e
    import_failure(e, dryrun: false)
  end

  def automatic_update_dryrun
    User.transaction do
      @import_proto = updater.update
      @log_timestamp = updater.log_timestamp
      @import_log_id = updater.import_log_id
      raise ActiveRecord::Rollback
    end
    import_success(dryrun: true)
  rescue StandardError => e
    import_failure(e, dryrun: true)
  end

  def import_success(dryrun: false)
    import_notification(:success, by: by, dryrun: dryrun)
    log_import(by: by) unless dryrun
    @success = true
  end

  def import_failure(error, dryrun: false)
    import_notification(:failure, by: by, dryrun: dryrun, error: error)
    @success = false
    @error = error
  end

  def import_notification(type, by: nil, dryrun: false, error: nil)
    title = type == :success ? 'Complete' : 'Failed'
    fallback = type == :success ? 'successfully imported' : 'failed to import'
    dry = dryrun ? '[Dryrun] ' : ''

    fields = fields(by, dryrun)
    fields << { title: 'Error Message', value: error.message, short: false } if type == :failure

    SlackNotification.new(
      channel: :notifications, type: type, title: "#{dry}User Data Import #{title}",
      fallback: "#{dry}User information has #{fallback}.",
      fields: fields,
      blocks: (blocks if dryrun && update_results != 'No changes' && type == :success)
    ).notify!

    return if update_results == 'No changes' || type != :success

    BPS::SlackFile.new('Update Results', update_results).call
  end

  def fields(by, dryrun)
    f = [
      { title: 'By', value: by, short: true },
      { title: 'Via', value: @via, short: true }
    ]
    f += live_results_fields unless dryrun
    f
  end

  def blocks
    token = @user.create_token(description: 'Automatic Update Slack button')

    [
      {
        'type': 'actions',
        'elements': [
          {
            'type': 'button',
            'text': { 'type': 'plain_text', 'emoji': true, 'text': 'Apply Changes' },
            'style': 'primary',
            'value': { key: token.key, token: token.new_token }.to_json
          }
        ]
      }
    ]
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
end
