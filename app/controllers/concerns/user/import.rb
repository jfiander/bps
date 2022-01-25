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
        @import_results = ImportUsers::Import.new(
          upload_import_file(uploaded_file), lock: clean_params[:lock_missing]
        ).call
        import_success
      rescue StandardError => e
        import_failure(e)
      end
    end

    def automatic_update
      @import_results = AutomaticUpdate::Run.new.update
      import_success
    rescue StandardError => e
      import_failure(e)
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
      flash.now[:success] = 'Successfully imported user data.'
      render :import
      import_notification(:success)
      log_import
    end

    def import_failure(error)
      flash.now[:alert] = 'Unable to import user data.'
      flash.now[:error] = error.message
      render :import
      import_notification(:failure)
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
