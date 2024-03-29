# frozen_string_literal: true

class User
  module Import
    ACCEPTABLE_CONTENT_TYPES = %w[
      text/csv text/plain application/octet-stream application/vnd.ms-excel
    ].freeze

    def import; end

    def do_import
      uploaded_file = clean_params[:import_file]
      return only_csv unless uploaded_file.content_type.in?(ACCEPTABLE_CONTENT_TYPES)

      begin
        importer = ImportUsers::Import.new(
          upload_import_file(uploaded_file), lock: clean_params[:lock_missing]
        )
        @import_proto = importer.call
        @log_timestamp = importer.log_timestamp
        @import_log_id = importer.import_log_id
        import_success
      rescue StandardError => e
        import_failure(e)
      end
    end

    def automatic_update
      run_automatic_import(dryrun: false)
    end

    def automatic_update_dryrun
      run_automatic_import(dryrun: true)
    end

    def invite_imported_users
      new_users = User.invitable_from(invite_imported_params[:users])

      if new_users.empty?
        flash[:notice] = 'No invitable users found.'
      else
        new_users.each(&:invite!)
        flash[:success] = "Successfully invited #{new_users.count} newly imported users!"
      end

      redirect_to(admin_import_log_path(invite_imported_params[:import_log_id]))
    end

  private

    def invite_imported_params
      params.permit(:import_log_id, users: [])
    end

    def only_csv
      flash.now[:alert] = 'You can only upload CSV files.'
      render :import
    end

    def upload_import_file(uploaded_file)
      import_path = Rails.root.join("tmp/run/#{Time.now.to_i}-users_import.csv").to_s
      file = File.open(import_path, 'w+')
      file.write(uploaded_file.read)
      file.close
      import_path
    end

    def run_automatic_import(dryrun:)
      @result = AutomaticUpdateJob.new.perform(
        current_user.id,
        dryrun: dryrun,
        via: 'UI',
        lock: clean_params[:lock_missing] == 'true'
      )
      @result.success? ? import_success : import_failure
    end

    def import_success
      flash.now[:success] = "Successfully #{@dryrun ? 'tested importing' : 'imported'} user data."
      @import_proto = @result.import_proto
      @log_timestamp = @result.log_timestamp
      @import_log_id = @result.import_log_id
      render :import
    end

    def import_failure
      flash.now[:alert] = 'Unable to import user data.'
      flash.now[:error] = @result.error.message
      Bugsnag.notify(@result.error)
      render :import
    end
  end
end
