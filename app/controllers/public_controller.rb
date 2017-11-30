class PublicController < ApplicationController
  before_action :list_bilges, only: [:newsletter, :get_bilge]
  before_action :time_formats, only: [:courses, :seminars, :events]
  before_action :render_markdown, only: [:home, :about, :join, :requirements, :vsc, :education, :civic, :history, :links]

  def home
    #
  end

  def about
    #
  end

  def join
    #
  end

  def requirements
    #
  end

  def vsc
    #
  end

  def education
    #
  end

  def civic
    #
  end

  def history
    #
  end

  def links
    #
  end
  
  def events
    @registered = Registration.where(user_id: current_user.id).map { |r| {r.event_id => r.id} }.reduce({}, :merge) if user_signed_in?
    @registered_users = Registration.all.group_by { |r| r.event_id }
    @events = get_events(params[:type], :current)
    @expired_events = get_events(params[:type], :expired)
  end

  def calendar
    #
  end

  def photos
    #
  end

  def bridge
    @bridge_officers = BridgeOffice.heads.ordered
    @committees = Committee.all.order(:name).group_by { |c| c.department }
    @standing_committees = StandingCommitteeOffice.committees.map(&:titleize)
    @standing_committee_members = StandingCommitteeOffice.current.order(chair: :desc).group_by { |s| s.committee_name }

    @users = [["TBD", nil]] + User.all.order(:last_name).to_a.map! do |user|
      return [user.email, user.id] if user.full_name.blank?
      [user.full_name, user.id]
    end

    @departments = BridgeOffice.ordered.heads.map { |b| [b.department, b.office] }
    @bridge_offices = BridgeOffice.ordered.map { |b| [b.title, b.office] }
  end

  def newsletter
    @years = @bilges.map(&:key).map { |b| b.sub("#{ENV['ASSET_ENVIRONMENT']}/", '').delete('.pdf').gsub(/\/(s|\d+)/, '') }.uniq

    @issues = @bilge_links.keys

    @available_issues = {
      1   => "Jan",
      2   => "Feb",
      3   => "Mar",
      4   => "Apr",
      5   => "May",
      6   => "Jun",
      "s" => "Sum",
      9   => "Sep",
      10  => "Oct",
      11  => "Nov",
      12  => "Dec"
    }
  end

  def get_bilge
    key = "#{ENV['ASSET_ENVIRONMENT']}/#{clean_params[:year]}/#{clean_params[:month]}"
    issue_link = @bilge_links[key]
    issue_title = key.gsub("/", "-")

    begin
      send_data open(issue_link).read, filename: "Bilge Chatter #{issue_title}.pdf", type: "application/pdf", disposition: 'inline'
    rescue SocketError => e
      newsletter
      render :newsletter, alert: "There was a problem accessing the Bilge Chatter. Please try again later."
    end
  end

  def store
    @store_items = StoreItem.all
    @store_item_requests = ItemRequest.outstanding
  end

  def register
    @event_id = clean_params[:event_id]
    unless Event.find_by(id: @event_id).allow_public_registrations
      flash[:alert] = "This course is not currently accepting public registrations."
      render status: :unprocessable_entity and return
    end

    registration_attributes = {email: clean_params[:email], event_id: @event_id}
    registration = Registration.new(registration_attributes)

    respond_to do |format|
      format.js do
        if registration.save
          flash[:notice] = "You have successfully registered!"
          render status: :success
        elsif Registration.find_by(registration_attributes)
          flash[:alert] = "You are already registered for this course."
          render status: :unprocessable_entity
        else
          flash[:alert] = "We are unable to register you at this time."
          render status: :unprocessable_entity
        end
      end
    end
  end

  def officer_flag(office)
    rank = case office
    when "commander"
      "CDR"
    when "executive", "educational", "administrative", "secretary", "treasurer"
      "LTC"
    when "asst_educational", "asst_secretary"
      "1LT"
    end

    BpsS3.get_object(bucket: :files, key: "static/flags/SVG/#{rank}.svg").get.body.read
  end
  helper_method :officer_flag

  private
  def clean_params
    params.permit(:year, :month, :email, :event_id)
  end

  def list_bilges
    @bilges = BpsS3.list(bucket: :bilge)

    @bilge_links = @bilges.map do |b|
      key = b.key.dup
      issue_date = b.key.delete(".pdf")
      { issue_date => BpsS3::CloudFront.link(bucket: :bilge, key: key) }
    end.reduce({}, :merge)
  end
  
  def get_events(type, scope = :current)
    case type
    when :course
      courses = {
        advanced_grades: Event.send(scope, :advanced_grades),
        electives: Event.send(scope, :electives)
      }

      courses.all? { |h| h.blank? } ? [] : courses
    when :seminar
      Event.send(scope, :seminars)
    when :event
      Event.send(scope, :meetings)
    end
   end
end
