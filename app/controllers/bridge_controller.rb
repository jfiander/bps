class BridgeController < ApplicationController
  include UserMethods
  include ApplicationHelper

  before_action :authenticate_user!, except: [:list]
  before_action except: [:list] { require_permission(:users) }
  skip_before_action :verify_authenticity_token, only: %i[auto_show auto_hide]

  skip_before_action :prerender_for_layout, only: %i[
    remove_committee remove_standing_committee
  ]

  before_action :get_users_for_select, only: %i[assign_bridge assign_committee]

  def list
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

  def assign_bridge
    bridge_office = BridgeOffice.find_by(office: clean_params[:bridge_office]) || BridgeOffice.create(office: clean_params[:bridge_office])
    if bridge_office.update(user_id: clean_params[:user_id])
      redirect_to bridge_path, success: "Successfully assigned to bridge office."
    else
      redirect_to bridge_path, alert: "Unable to assign to bridge office."
    end
  end

  def assign_committee
    committee = Committee.create(name: clean_params[:committee], department: clean_params[:department], user_id: clean_params[:user_id])
    if committee.valid?
      redirect_to bridge_path, success: "Successfully assigned to committee."
    else
      redirect_to bridge_path, alert: "Unable to assign to committee."
    end
  end

  def remove_committee
    @committee_id = clean_params[:id]
    if Committee.find_by(id: @committee_id)&.destroy
      flash[:success] = "Successfully removed committee assignment."
      @do_remove = true
    else
      flash[:alert] = "Unable to remove committee assignment."
      @do_remove = false
    end
  end

  def assign_standing_committee
    y = clean_params[:term_start_at]["(1i)"]
    m = clean_params[:term_start_at]["(2i)"]
    d = clean_params[:term_start_at]["(3i)"]
    term_start = "#{y}-#{m}-#{d}"
    standing_committee = StandingCommitteeOffice.new(committee_name: clean_params[:committee_name], chair: clean_params[:chair], user_id: clean_params[:user_id], term_start_at: term_start, term_length: clean_params[:term_length])
    if standing_committee.save
      redirect_to bridge_path, success: "Successfully assigned to standing committee."
    else
      redirect_to bridge_path, alert: "Unable to assign to standing committee."
    end
  end

  def remove_standing_committee
    @standing_committee_id = clean_params[:id]
    if StandingCommitteeOffice.find_by(id: @standing_committee_id)&.destroy
      flash[:success] = "Successfully removed standing committee assignment."
      @do_remove = true
    else
      flash[:alert] = "Unable to remove from standing committee."
      @do_remove = false
    end
  end

  private

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
