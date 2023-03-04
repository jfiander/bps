# frozen_string_literal: true

module V2
  class BilgesController < ApplicationController
    secure!(:newsletter, only: %i[create])
    title!('The Bilge Chatter')

    def index
      last_18 = BilgeFile.last_18
      @bilges = user_signed_in? ? BilgeFile.ordered : last_18
      @public_ids = last_18.map(&:id)
      @issues = BilgeFile.issues
      load_announcements
    end

    def bilge
      bilge = pick_bilge
      return bilge_not_found if bilge.blank?

      send_bilge(bilge)
    end

    def upload
      verb = update_bilge
      issue = "#{bilge_params[:issue]['date(1i)']}/#{bilge_params[:issue]['date(2i)']}"

      notify_for_bilge if bilge_params[:bilge_notify]
      redirect_to(v2_bilges_path, success: "Bilge Chatter #{issue} #{verb} successfully.")
    end

  private

    def bilge_params
      params.permit(
        :id, :page_name, :save, :preview, :file, :bilge_remove, :bilge_notify,
        issue: ['date(1i)', 'date(2i)']
      )
    end

    def find_bilge_issue
      BilgeFile.find_by(
        year: bilge_params[:issue]['date(1i)'],
        month: bilge_params[:issue]['date(2i)']
      )
    end

    def load_announcements
      @announcements = AnnouncementFile.ordered
      @announcements = @announcements.visible unless current_user&.permitted?(:newsletter)
    end

    def update_bilge
      if bilge_params[:bilge_remove].present?
        find_bilge_issue&.destroy
        'removed'
      elsif (file = find_bilge_issue).present?
        file.update(file: bilge_params[:file])
        notify_for_bilge if bilge_params[:bilge_notify]
        'replaced'
      else
        create_bilge
        notify_for_bilge if bilge_params[:bilge_notify]
        'uploaded'
      end
    end

    def create_bilge
      BilgeFile.create(
        year: bilge_params[:issue]['date(1i)'],
        month: bilge_params[:issue]['date(2i)'],
        file: bilge_params[:file]
      )
    end

    def bilge_not_found
      index
      flash.now[:alert] = 'There was a problem accessing the Bilge Chatter.'
      flash.now[:error] = 'Issue not found.'
      render :index
    end

    def send_bilge(bilge)
      send_data(
        URI.parse(BPS::S3.new(:bilge).link(bilge.file.s3_object.key)).open.read,
        filename: "Bilge Chatter - #{bilge.full_issue}.pdf",
        type: 'application/pdf',
        disposition: 'inline'
      )
    rescue SocketError
      newsletter
      flash.now[:alert] = 'There was a problem accessing the Bilge Chatter. Please try again later.'
      render :newsletter
    end

    def notify_for_bilge
      editor = Committee.where(department: :secretary, name: 'Newsletter Editor')
      membership = Committee.where(department: :administrative, name: 'Membership')
      web = Committee.where(department: :secretary, name: 'Webmaster')

      NotificationsMailer.bilge(
        editor.or(membership).or(web).map { |c| c.user.email }.compact,
        year: bilge_params[:issue]['date(1i)'],
        month: bilge_params[:issue]['date(2i)']
      ).deliver
    end
  end
end
