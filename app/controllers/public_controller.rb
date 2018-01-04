class PublicController < ApplicationController
  MARKDOWN_EDITABLE_VIEWS ||= [:home, :about, :join, :requirements, :vsc, :education, :civic, :history, :links].freeze
  # STATIC_VIEWS = [:calendar, :photos].freeze

  before_action :list_bilges, only: [:newsletter, :get_bilge]
  before_action :time_formats, only: [:courses, :seminars, :events]
  before_action :render_markdown, only: MARKDOWN_EDITABLE_VIEWS

  MARKDOWN_EDITABLE_VIEWS.each { |m| define_method(m) {} }
  
  def events
    event_includes = [:event_instructors, :instructors, :event_type]
    event_includes += [:course_topics, :course_includes, :prereq] if params[:type] == :course
    @all_events = Event.includes(event_includes).order(:start_at)
    @events = get_events(params[:type], :current)
    @registered = Registration.includes(:user).where(user_id: current_user.id).map { |r| {r.event_id => r.id} }.reduce({}, :merge) if user_signed_in?

    @current_user_permitted_event_type = current_user&.permitted?(params[:type])

    if current_user&.permitted?(params[:type])
      @registered_users = Registration.includes(:user).all.group_by { |r| r.event_id }
      @expired_events = get_events(params[:type], :expired)
    end
  end

  def bridge
    # Only load roles for editing permissions once
    @current_user_permitted_users = current_user&.permitted?(:users)

    # Preload all needed data
    @users = User.order(:last_name).includes(:bridge_office, :committees, :standing_committee_offices)
    all_bridge_officers = BridgeOffice.ordered
    @all_committees = Committee.sorted
    standing_committees = StandingCommitteeOffice.current.chair_first.group_by { |s| s.committee_name }

    # Build lists for form selectors
    @select = {}
    @select[:departments] = BridgeOffice.departments.map { |b| [b.titleize, b] }
    @select[:bridge_offices] = BridgeOffice.departments(assistants: true).map { |b| [BridgeOffice.title(b), b] }
    @select[:standing_committees] = StandingCommitteeOffice.committee_titles
    @select[:users] = [["TBD", nil]] + @users.to_a.map! do |user|
      return [user.email, user.id] if user&.full_name.blank?
      [user.full_name, user.id]
    end

    # Assemble data for view
    @bridge_list = {}
    department_data = {}
    standing_committee_data = {}
    BridgeOffice.departments.each do |dept|
      head = all_bridge_officers.find_all { |b| b.office == dept }.first
      assistant = all_bridge_officers.find_all { |b| b.office == "asst_#{dept}" }.first
      department_data[dept.to_sym] = {}
      department_data[dept.to_sym][:head] = generate_dept_head(dept, head)
      department_data[dept.to_sym][:assistant] = generate_dept_asst(dept, assistant) if assistant.present?
      department_data[dept.to_sym][:committees] = generate_committees(dept)
    end
    standing_committees.each do |committee, members|
      standing_committee_data[committee] = []
      members.each do |member|
        user = get_user(member.user_id)
        standing_committee_data[committee] << {
          id: member.id,
          simple_name: user[:simple_name],
          full_name: user[:full_name],
          chair: member.chair.present?,
          term_fraction: member.term_fraction
        }
      end
    end

    @bridge_list = {
      departments: department_data,
      standing_committees: standing_committee_data
    }
  end

  def get_user(id)
    user = @users.find_all { |u| u.id == id }.first

    return user.bridge_hash if user.present?

    {
      full_name: "TBD",
      simple_name: "TBD",
      photo: User.no_photo
    }
  end
  helper_method :get_user

  def newsletter
    @years = @bilges.map(&:key).map { |b| b.sub('.pdf', '').sub(/\/(s|\d+)$/, '').delete('/') }.uniq.reject { |b| b.blank? }

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
    key = "#{clean_params[:year]}/#{clean_params[:month]}"
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
        if Registration.find_by(registration_attributes)
          flash[:alert] = "You are already registered for this course."
          render status: :unprocessable_entity
        elsif registration.save
          flash[:notice] = "You have successfully registered!"
        else
          flash[:alert] = "We are unable to register you at this time."
          render status: :unprocessable_entity
        end
      end
    end
  end

  private
  def clean_params
    params.permit(:year, :month, :email, :event_id)
  end

  def list_bilges
    @bilges = bilge_bucket.list

    @bilge_links = @bilges.map(&:key).map do |b|
      { b.delete(".pdf") => bilge_bucket.link(key: b) }
    end.reduce({}, :merge)
  end
  
  def get_events(type, scope = :current)
    scoped_events = {
      current: @all_events.find_all { |e| e.expires_at > Time.now },
      expired: @all_events.find_all { |e| e.expires_at <= Time.now }
    }

    case type
    when :course
      courses = {
        public: scoped_events[scope].find_all { |c| c.event_type.event_category == "public" },
        advanced_grades: scoped_events[scope].find_all { |c| c.event_type.event_category == "advanced_grade" },
        electives: scoped_events[scope].find_all { |c| c.event_type.event_category == "elective" }
      }

      courses.all? { |h| h.blank? } ? [] : courses
    when :seminar
      scoped_events[scope].find_all { |c| c.event_type.event_category == "seminar" }
    when :event
      scoped_events[scope].find_all { |c| c.event_type.event_category == "meeting" }
    end
  end
  
  def generate_dept_head(dept, head)
    {
      title: BridgeOffice.title(dept),
      office: dept,
      email: head&.email,
      user: get_user(head&.user_id)
    }
  end
  
  def generate_dept_asst(dept, assistant)
    {
      title: assistant&.title,
      office: assistant&.office,
      email: assistant&.email,
      user: get_user(assistant&.user_id)
    }
  end

  def generate_committees(dept)
    @all_committees[dept]&.map do |c|
      {
        name: c.display_name,
        user: get_user(c.user_id),
        id: c.id
      }
    end
  end
end
