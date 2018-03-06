module BridgeHelper
  def bridge_selectors
    @select = {}
    @select[:departments] = BridgeOffice.departments.map { |b| [b.titleize, b] }
    @select[:bridge_offices] = BridgeOffice.departments(assistants: true).map { |b| [BridgeOffice.title(b), b] }
    @select[:standing_committees] = StandingCommitteeOffice.committee_titles
    @select[:users] = [['TBD', nil]] + @users.to_a.map! do |user|
      user&.full_name.blank? ? [user.email, user.id] : [user.full_name, user.id]
    end
  end

  def preload_user_data
    @users = User.unlocked.order(:last_name).includes(
      :bridge_office, :committees, :standing_committee_offices
    )
    @all_bridge_officers = BridgeOffice.ordered
    @all_committees = Committee.sorted
    @standing_coms = StandingCommitteeOffice.current.chair_first
                                            .group_by(&:committee_name)
  end

  def assemble_bridge_data
    @bridge_list = {}
    @department_data = {}
    @standing_committee_data = {}

    assemble_departments
    assemble_standing_committees
  end

  def assemble_departments
    BridgeOffice.departments.each do |dept|
      head = @all_bridge_officers.find_all { |b| b.office == dept }.first
      assistant = @all_bridge_officers.find_all { |b| b.office == "asst_#{dept}" }.first
      @department_data[dept.to_sym] = {}
      @department_data[dept.to_sym][:head] = generate_dept_head(dept, head)
      @department_data[dept.to_sym][:assistant] = generate_dept_asst(dept, assistant) if assistant.present?
      @department_data[dept.to_sym][:committees] = generate_committees(dept)
    end
  end

  def assemble_standing_committees
    @standing_coms.each do |committee, members|
      @standing_committee_data[committee] = []
      members.each do |member|
        user = get_user(member.user_id)
        @standing_committee_data[committee] << standing_committee(member, user)
      end
    end
  end

  def standing_committee(member, user)
    {
      id: member.id,
      simple_name: user[:simple_name],
      full_name: user[:full_name],
      chair: member.chair.present?,
      term_fraction: member.term_fraction
    }
  end

  def build_bridge_list
    @bridge_list = {
      departments: @department_data,
      standing_committees: @standing_committee_data
    }
  end
end
