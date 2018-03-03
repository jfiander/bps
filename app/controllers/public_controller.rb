class PublicController < ApplicationController
  skip_before_action :prerender_for_layout, only: [:register]

  before_action :list_bilges, only: %i[newsletter get_bilge]

  before_action only: [:bridge] { page_title('Bridge Officers') }
  before_action only: [:newsletter] { page_title('The Bilge Chatter') }
  before_action only: [:store] { page_title("Ship's Store") }
  before_action only: [:calendar] { page_title('Calendar') }
  before_action only: [:events] do
    page_title("#{params[:type].to_s.titleize}s")
  end
  before_action only: [:catalog] do
    page_title("#{params[:type].to_s.titleize} Catalog")
  end

  render_markdown_views

  def newsletter
    @years = bilge_years
    @years = @years.last(2) unless user_signed_in?
    @issues = @bilge_links.keys

    @available_issues = available_bilge_issues
  end

  def get_bilge
    key = "#{clean_params[:year]}/#{clean_params[:month]}"
    issue_link = @bilge_links[key]
    issue_title = key.tr('/', '-')

    if issue_link.blank?
      newsletter
      flash.now[:alert] = 'There was a problem accessing the Bilge Chatter.'
      flash.now[:error] = 'Issue not found.'
      render :newsletter
      return
    end

    begin
      send_data(
        open(issue_link).read,
        filename: "Bilge Chatter #{issue_title}.pdf",
        type: 'application/pdf',
        disposition: 'inline'
      )
    rescue SocketError
      newsletter
      flash.now[:alert] = 'There was a problem accessing the Bilge Chatter. Please try again later.'
      render :newsletter
    end
  end

  def store
    @store_items = StoreItem.all
    @store_item_requests = ItemRequest.outstanding
  end

  def register
    if params.key?(:registration)
      @event_id = register_params[:event_id]
      registration_attributes = register_params.to_hash.symbolize_keys
    else
      @event_id = clean_params[:event_id]
      registration_attributes = {
        event_id: @event_id,
        email: clean_params[:email]
      }
    end

    @event = Event.find_by(id: @event_id)

    unless @event.allow_public_registrations
      flash.now[:alert] = 'This course is not currently accepting public registrations.'
      render status: :unprocessable_entity
      return
    end

    unless @event.registerable?
      flash.now[:alert] = 'This course is no longer accepting registrations.'
      render status: :unprocessable_entity
      return
    end

    registration = Registration.new(registration_attributes)

    respond_to do |format|
      format.js do
        if Registration.find_by(registration_attributes)
          flash[:alert] = 'You are already registered for this course.'
          render status: :unprocessable_entity
        elsif registration.save
          flash[:success] = 'You have successfully registered!'
        else
          flash[:alert] = 'We are unable to register you at this time.'
          render status: :unprocessable_entity
        end
      end

      format.html do
        event_type = @event.category
        event_type = :event if event_type == :meeting

        if Registration.find_by(registration_attributes)
          flash[:alert] = 'You are already registered for this course.'
        elsif registration.save
          flash[:success] = 'You have successfully registered!'
        else
          flash[:alert] = 'We are unable to register you at this time.'
        end
        redirect_to send("show_#{event_type}_path", id: @event_id)
      end
    end
  end

  private

  def clean_params
    params.permit(:year, :month, :email, :event_id)
  end

  def register_params
    params.require(:registration).permit(:event_id, :name, :email, :phone)
  end

  def list_bilges
    @bilges = bilge_bucket.list

    @bilge_links = @bilges.map(&:key).map do |b|
      { b.delete('.pdf') => bilge_bucket.link(b) }
    end.reduce({}, :merge)
  end

  def bilge_years
    @bilges
      .map(&:key)
      .map { |b| b.sub('.pdf', '').sub(%r{/(s|\d+)$}, '').delete('/') }
      .uniq
      .reject(&:blank?)
  end

  def available_bilge_issues
    {
      1   => 'Jan',
      2   => 'Feb',
      3   => 'Mar',
      4   => 'Apr',
      5   => 'May',
      6   => 'Jun',
      's' => 'Sum',
      9   => 'Sep',
      10  => 'Oct',
      11  => 'Nov',
      12  => 'Dec'
    }
  end
end
