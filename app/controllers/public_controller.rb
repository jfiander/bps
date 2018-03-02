class PublicController < ApplicationController
  include EventsHelper

  before_action :list_bilges, only: [:newsletter, :get_bilge]
  before_action :time_formats, only: [:events, :catalog]
  before_action :preload_events, only: [:events, :catalog]

  before_action only: [:events] { page_title("#{params[:type].to_s.titleize}s") }
  before_action only: [:catalog] { page_title("#{params[:type].to_s.titleize} Catalog") }
  before_action only: [:bridge] { page_title('Bridge Officers') }
  before_action only: [:newsletter] { page_title('The Bilge Chatter') }
  before_action only: [:store] { page_title("Ship's Store") }
  before_action only: [:calendar] { page_title('Calendar') }

  render_markdown_views

  def events
    @events = get_events(params[:type], :current)
    @registered = Registration.includes(:user).where(user_id: current_user.id).map { |r| {r.event_id => r.id} }.reduce({}, :merge) if user_signed_in?
    @locations = Location.searchable

    @current_user_permitted_event_type = current_user&.permitted?(params[:type])

    if current_user&.permitted?(params[:type])
      @registered_users = Registration.includes(:user).all.group_by { |r| r.event_id }
      @expired_events = get_events(params[:type], :expired)
    end
  end

  def catalog
    @event_catalog = if params[:type] == :course
      @catalog.slice('public', 'advanced_grade', 'elective').symbolize_keys
    else
      @catalog[params[:type].to_s]
    end
  end

  def bridge
    # Only load roles for editing permissions once
    @current_user_permitted_users = current_user&.permitted?(:users)

    # Preload all needed data
    @users = User.unlocked.order(:last_name).includes(:bridge_office, :committees, :standing_committee_offices)
    all_bridge_officers = BridgeOffice.ordered
    @all_committees = Committee.sorted
    standing_committees = StandingCommitteeOffice.current.chair_first.group_by { |s| s.committee_name }

    # Build lists for form selectors
    @select = {}
    @select[:departments] = BridgeOffice.departments.map { |b| [b.titleize, b] }
    @select[:bridge_offices] = BridgeOffice.departments(assistants: true).map { |b| [BridgeOffice.title(b), b] }
    @select[:standing_committees] = StandingCommitteeOffice.committee_titles
    @select[:users] = [['TBD', nil]] + @users.to_a.map! do |user|
      user&.full_name.blank? ? [user.email, user.id] : [user.full_name, user.id]
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
      full_name: 'TBD',
      simple_name: 'TBD',
      photo: User.no_photo
    }
  end
  helper_method :get_user

  def newsletter
    @years = @bilges.map(&:key).map { |b| b.sub('.pdf', '').sub(/\/(s|\d+)$/, '').delete('/') }.uniq.reject { |b| b.blank? }

    @years = @years.last(2) unless user_signed_in?

    @issues = @bilge_links.keys

    @available_issues = {
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
      send_data open(issue_link).read, filename: "Bilge Chatter #{issue_title}.pdf", type: 'application/pdf', disposition: 'inline'
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
    if params.has_key?(:registration)
      @event_id = register_params[:event_id]
      registration_attributes = register_params.to_hash.symbolize_keys
    else
      @event_id = clean_params[:event_id]
      registration_attributes = { event_id: @event_id, email: clean_params[:email] }
    end

    @event = Event.find_by(id: @event_id)

    unless @event.allow_public_registrations
      flash.now[:alert] = 'This course is not currently accepting public registrations.'
      render status: :unprocessable_entity and return
    end

    unless @event.registerable?
      flash.now[:alert] = 'This course is no longer accepting registrations.'
      render status: :unprocessable_entity and return
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
        event_type = if @event.course?(@event_types)
          :course
        elsif @event.seminar?(@event_types)
          :seminar
        else
          :event
        end

        if Registration.find_by(registration_attributes)
          flash[:alert] = 'You are already registered for this course.'
          redirect_to send("show_#{event_type}_path", id: @event_id)
        elsif registration.save
          flash[:success] = 'You have successfully registered!'
          redirect_to send("show_#{event_type}_path", id: @event_id)
        else
          flash[:alert] = 'We are unable to register you at this time.'
          redirect_to send("show_#{event_type}_path", id: @event_id)
        end
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

  def get_events(type, scope = :current)
    @scoped_events ||= {
      current: @all_events.find_all { |e| !e.expired? },
      expired: @all_events.find_all(&:expired?)
    }

    @event_types ||= EventType.all
    @event_type_ids ||= @event_types.group_by(&:event_category).map do |c, t|
      { c => t.map(&:id) }
    end.reduce({}, :merge)

    case type
    when :course
      courses = {
        public: @scoped_events[scope].find_all do |c|
          c.event_type_id.in?(@event_type_ids['public'])
        end,
        advanced_grade: @scoped_events[scope].find_all do |c|
          c.event_type_id.in?(@event_type_ids['advanced_grade'])
        end,
        elective: @scoped_events[scope].find_all do |c|
          c.event_type_id.in?(@event_type_ids['elective'])
        end
      }

      courses.all?(&:blank?) ? [] : courses
    when :seminar
      @scoped_events[scope].find_all do |c|
        c.event_type_id.in?(@event_type_ids['seminar'])
      end
    when :event
      @scoped_events[scope].find_all do |c|
        c.event_type_id.in?(@event_type_ids['meeting'])
      end
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
