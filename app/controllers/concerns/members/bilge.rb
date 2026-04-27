# frozen_string_literal: true

module Members
  module Bilge
    def upload_bilge
      verb = update_file(:bilge)
      issue = "#{bilge_params[:issue]['date(1i)']}/#{bilge_params[:issue]['date(2i)']}"

      notify_for_bilge if bilge_params[:bilge_notify]

      redirect_to(
        newsletter_path,
        success: "Bilge Chatter #{issue} #{verb} successfully."
      )
    end

  private

    def find_bilge_issue
      BilgeFile.find_by(
        year: bilge_params[:issue]['date(1i)'],
        month: bilge_params[:issue]['date(2i)']
      )
    end

    def bilge_params
      params.permit(
        :id, :page_name, :save, :preview, :file, :bilge_remove, :bilge_notify,
        issue: ['date(1i)', 'date(2i)']
      )
    end

    def remove_bilge
      find_bilge_issue&.destroy
    end

    def create_bilge
      BilgeFile.create(
        year: bilge_params[:issue]['date(1i)'],
        month: bilge_params[:issue]['date(2i)'],
        file: bilge_params[:file]
      )
    end

    def notify_for_bilge
      editor = Committee.where(department: :secretary, name: 'Newsletter Editor')
      membership = Committee.where(department: :administrative, name: 'Membership')
      web = Committee.where(department: :secretary, name: 'Webmaster')

      year = bilge_params[:issue]['date(1i)']
      month = bilge_params[:issue]['date(2i)']

      NotificationsMailer.bilge(
        editor.or(membership).or(web).map { |c| c.user.email }.compact, year: year, month: month
      ).deliver

      bilge_slack_notification(year, month)
    end

    def bilge_slack_notification(year, month)
      SlackNotification.new(
        channel: :notifications, type: :info, title: 'Bilge Chatter Posted',
        fallback: 'A Bilge Chatter issue has been posted.',
        fields: {
          'Year' => year,
          'Issue' => BilgeFile.issues[month],
          'Link' => bilge_url(year: year, month: month)
        }
      ).notify!
    end
  end
end
