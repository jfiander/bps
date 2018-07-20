# frozen_string_literal: true

module User::Import
  def import
    #
  end

  def do_import
    uploaded_file = clean_params[:import_file]

    unless uploaded_file.content_type == 'text/csv'
      flash.now[:alert] = 'You can only upload CSV files.'
      render :import
      return
    end

    import_path = "#{Rails.root}/tmp/#{Time.now.to_i}-users_import.csv"
    file = File.open(import_path, 'w+')
    file.write(uploaded_file.read)
    file.close
    begin
      @import_results = ImportUsers.new.call(
        import_path, lock: clean_params[:lock_missing]
      )
      flash.now[:success] = 'Successfully imported user data.'
      render :import
    rescue StandardError => e
      flash.now[:alert] = 'Unable to import user data.'
      flash.now[:error] = e.message
      render :import
    end

    import_notification
  end

  private

  def import_notification
    SlackNotification.new(
      type: :info, title: 'User Data Import Complete',
      fallback: 'User information has been successfully imported.',
      fields: [
        { title: 'By', value: current_user.full_name, short: true },
        { title: 'Results', value: @import_results.to_s, short: false }
      ]
    ).notify!
  end
end
