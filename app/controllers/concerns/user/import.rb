# frozen_string_literal: true

class User
  module Import
    ACCEPTABLE_CONTENT_TYPES ||= %w[
      text/csv text/plain application/octet-stream application/vnd.ms-excel
    ].freeze

    def import; end

    def do_import
      uploaded_file = clean_params[:import_file]
      return only_csv unless uploaded_file.content_type.in?(ACCEPTABLE_CONTENT_TYPES)

      begin
        @import_proto = ImportUsers::Import.new(
          upload_import_file(uploaded_file), lock: clean_params[:lock_missing]
        ).call
        import_success
      rescue StandardError => e
        import_failure(e)
      end
    end

    def automatic_update
      @import_proto = AutomaticUpdate::Run.new.update
      import_success
    rescue StandardError => e
      import_failure(e)
    end

    def automatic_update_dryrun
      @dryrun = true

      User.transaction do
        automatic_update
        raise ActiveRecord::Rollback
      end
    end

  private

    def only_csv
      flash.now[:alert] = 'You can only upload CSV files.'
      render :import
    end

    def upload_import_file(uploaded_file)
      import_path = "#{Rails.root}/tmp/run/#{Time.now.to_i}-users_import.csv"
      file = File.open(import_path, 'w+')
      file.write(uploaded_file.read)
      file.close
      import_path
    end

    def import_success
      flash.now[:success] = "Successfully #{@dryrun ? 'tested importing' : 'imported'} user data."
      render :import
      import_notification(:success)
      log_import
    end

    def import_failure(error)
      flash.now[:alert] = 'Unable to import user data.'
      flash.now[:error] = error.message
      Bugsnag.notify(error)
      render :import
      import_notification(:failure)
    end

    def import_notification(type)
      SlackNotification.new(
        channel: :notifications, type: type, title: "User Data Import #{notification_title(type)}",
        fallback: "User information has #{notification_fallback(type)}.",
        fields: [
          { title: 'By', value: current_user.full_name, short: true },
          { title: 'Results', value: @import_proto.to_json, short: false }
        ]
      ).notify!
    end

    def notification_title(type)
      return "#{'Test ' if @dryrun}Complete" if type == :success

      "#{'Test ' if @dryrun}Failed"
    end

    def notification_fallback(type)
      return "successfully #{@dryrun ? 'tested importing' : 'imported'}" if type == :success

      "failed to #{@dryrun ? 'test importing' : 'import'}"
    end

    def log_import
      log = File.open("#{Rails.root}/log/user_import.log", 'a')

      log.write("[#{Time.now}] User import by: #{current_user.full_name}\n")
      log.write(@import_proto.to_json)
      log.write("\n\n")
      log.close
    end
  end
end
